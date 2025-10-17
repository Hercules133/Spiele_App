import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/game.dart';
import '../models/game_player.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

class KniffelGameScreen extends StatefulWidget {
  final int gameId;
  final List<Player> players;

  const KniffelGameScreen({
    super.key,
    required this.gameId,
    required this.players,
  });

  @override
  State<KniffelGameScreen> createState() => _KniffelGameScreenState();
}

class _KniffelGameScreenState extends State<KniffelGameScreen> {
  final _dbService = DatabaseService.instance;
  // int _currentPlayerIndex = 0; // Nicht mehr benötigt
  final Map<int, Map<String, int?>> _playerScores = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'Einser',
    'Zweier',
    'Dreier',
    'Vierer',
    'Fünfer',
    'Sechser',
    'Dreierpasch',
    'Viererpasch',
    'Full House',
    'Kleine Straße',
    'Große Straße',
    'Kniffel',
    'Chance',
  ];

  @override
  void initState() {
    super.initState();
    _initScores();
    _loadGameData();
  }

  void _initScores() {
    for (var player in widget.players) {
      _playerScores[player.id!] = {};
      for (var category in _categories) {
        _playerScores[player.id!]![category] = null;
      }
    }
  }

  Future<void> _loadGameData() async {
    setState(() => _isLoading = true);

    for (var player in widget.players) {
      final scores = await _dbService.getPlayerScoresForGame(
        widget.gameId,
        player.id!,
      );

      for (var score in scores) {
        if (score.metadata != null) {
          final metadata = jsonDecode(score.metadata!);
          final category = metadata['category'] as String;
          _playerScores[player.id!]![category] = score.score;
        }
      }
    }

    setState(() => _isLoading = false);
  }

  int _getUpperSectionTotal(int playerId) {
    int total = 0;
    final upperCategories = _categories.sublist(0, 6);
    for (var category in upperCategories) {
      total += _playerScores[playerId]![category] ?? 0;
    }
    return total;
  }

  int _getBonus(int playerId) {
    return _getUpperSectionTotal(playerId) >= 63 ? 35 : 0;
  }

  int _getLowerSectionTotal(int playerId) {
    int total = 0;
    final lowerCategories = _categories.sublist(6);
    for (var category in lowerCategories) {
      total += _playerScores[playerId]![category] ?? 0;
    }
    return total;
  }

  int _getTotalScore(int playerId) {
    return _getUpperSectionTotal(playerId) +
        _getBonus(playerId) +
        _getLowerSectionTotal(playerId);
  }

  bool _isGameComplete() {
    for (var playerId in _playerScores.keys) {
      for (var category in _categories) {
        if (_playerScores[playerId]![category] == null) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _saveScore(String category, int score) async {
    // Spieler explizit übergeben
    // Diese Methode wird jetzt mit playerId aufgerufen
    final playerId = playerIdForDialog;

    if (_playerScores[playerId]![category] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diese Kategorie ist bereits belegt!')),
      );
      return;
    }

    final metadata = jsonEncode({'category': category});

    await _dbService.createGameScore(
      GameScore(
        gameId: widget.gameId,
        playerId: playerId,
        round: 0, // Kniffel hat keine Runden
        score: score,
        metadata: metadata,
      ),
    );

    setState(() {
      _playerScores[playerId]![category] = score;
    });

    if (_isGameComplete()) {
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    final game = await _dbService.getGame(widget.gameId);
    if (game != null) {
      await _dbService.updateGame(
        game.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );

      final gamePlayers = await _dbService.getGamePlayers(widget.gameId);
      for (var gamePlayer in gamePlayers) {
        final totalScore = _getTotalScore(gamePlayer.playerId);
        await _dbService.updateGamePlayer(
          gamePlayer.copyWith(totalScore: totalScore),
        );
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final sortedPlayers = [...widget.players];
        sortedPlayers.sort(
            (a, b) => _getTotalScore(b.id!).compareTo(_getTotalScore(a.id!)));

        return AlertDialog(
          title: const Text('Spiel beendet!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Endergebnis:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...sortedPlayers.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final player = entry.value;
                final score = _getTotalScore(player.id!);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '$rank. ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(player.name),
                      const Spacer(),
                      Text(
                        '$score Punkte',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Zurück zum Hauptmenü'),
            ),
          ],
        );
      },
    );
  }

  void _showScoreDialog(String category, int playerId) {
    final controller = TextEditingController();
    String? errorText;
    // Feste Punkte für bestimmte Kategorien
    final fixedPoints = {
      'Full House': 25,
      'Kleine Straße': 30,
      'Große Straße': 40,
      'Kniffel': 50,
    };
    bool isFixedCategory = fixedPoints.containsKey(category);
    void save(BuildContext dialogContext) {
      int? score;
      if (isFixedCategory) {
        score = fixedPoints[category];
      } else {
        score = int.tryParse(controller.text.trim());
        if (score == null) {
          errorText = 'Bitte eine gültige Zahl eingeben.';
          (dialogContext as Element).markNeedsBuild();
          return;
        }
        // Validierung für Einser bis Sechser
        final upperCategories = _categories.sublist(0, 6);
        if (upperCategories.contains(category)) {
          final augenzahl = upperCategories.indexOf(category) + 1;
          if (score % augenzahl != 0) {
            errorText = 'Die Zahl muss durch $augenzahl teilbar sein!';
            (dialogContext as Element).markNeedsBuild();
            return;
          }
          if (score > 5 * augenzahl) {
            errorText = 'Maximal ${5 * augenzahl} Punkte möglich (5 Würfel)!';
            (dialogContext as Element).markNeedsBuild();
            return;
          }
        }
      }
      playerIdForDialog = playerId;
      _saveScore(category, score!);
      Navigator.pop(dialogContext);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              '$category – ${widget.players.firstWhere((p) => p.id == playerId).name}'),
          content: isFixedCategory
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(category == 'Kniffel'
                      ? 'Wenn erfüllt, werden automatisch 50 Punkte eingetragen.'
                      : 'Wenn erfüllt, werden automatisch ${fixedPoints[category]} Punkte eingetragen.'),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Punkte',
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                      ),
                      keyboardType: TextInputType.number,
                      autofocus: true,
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                errorText = null;
                setState(() {});
                save(dialogContext);
              },
              child: Text(isFixedCategory ? 'Erfüllt' : 'Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  // Hilfsvariable, um playerId an _saveScore zu übergeben
  int playerIdForDialog = -1;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kniffel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (!_isGameComplete())
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Text(
                'Klicke auf ein leeres Feld, um Punkte einzutragen.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                    columns: [
                      const DataColumn(
                        label: Text(
                          'Kategorie',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...widget.players.map((player) {
                        return DataColumn(
                          label: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ],
                    rows: [
                      ..._categories.map((category) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(category),
                            ),
                            ...widget.players.map((player) {
                              final score =
                                  _playerScores[player.id!]![category];
                              return DataCell(
                                Text(score?.toString() ?? '-'),
                                onTap: !_isGameComplete() && score == null
                                    ? () =>
                                        _showScoreDialog(category, player.id!)
                                    : null,
                              );
                            }),
                          ],
                        );
                      }),
                      // Upper section total
                      DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          return Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[900]?.withOpacity(0.3)
                              : Colors.blue[50];
                        }),
                        cells: [
                          const DataCell(
                            Text(
                              'Obere Summe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...widget.players.map((player) {
                            final total = _getUpperSectionTotal(player.id!);
                            return DataCell(
                              Text(
                                '$total',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Bonus
                      DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          return Theme.of(context).brightness == Brightness.dark
                              ? Colors.green[900]?.withOpacity(0.3)
                              : Colors.green[50];
                        }),
                        cells: [
                          const DataCell(
                            Text(
                              'Bonus (≥63)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...widget.players.map((player) {
                            final bonus = _getBonus(player.id!);
                            return DataCell(
                              Text(
                                bonus > 0 ? '+$bonus' : '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bonus > 0
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green[300]
                                          : Colors.green[700])
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Lower section total
                      DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          return Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[900]?.withOpacity(0.3)
                              : Colors.blue[50];
                        }),
                        cells: [
                          const DataCell(
                            Text(
                              'Untere Summe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...widget.players.map((player) {
                            final total = _getLowerSectionTotal(player.id!);
                            return DataCell(
                              Text(
                                '$total',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Total
                      DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          return Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber[900]?.withOpacity(0.3)
                              : Colors.amber[100];
                        }),
                        cells: [
                          const DataCell(
                            Text(
                              'GESAMT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...widget.players.map((player) {
                            final total = _getTotalScore(player.id!);
                            return DataCell(
                              Text(
                                '$total',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
