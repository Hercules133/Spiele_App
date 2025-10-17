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
  int _currentPlayerIndex = 0;
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
    final playerId = widget.players[_currentPlayerIndex].id!;

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

      // Move to next player
      if (!_isGameComplete()) {
        _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
      }
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

  void _showScoreDialog(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Punkte',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final score = int.tryParse(controller.text.trim());
              if (score != null) {
                _saveScore(category, score);
                Navigator.pop(context);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlayer = widget.players[_currentPlayerIndex];

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
              child: Text(
                'Am Zug: ${currentPlayer.name}',
                style: const TextStyle(
                  fontSize: 20,
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
                              onTap: !_isGameComplete()
                                  ? () => _showScoreDialog(category)
                                  : null,
                            ),
                            ...widget.players.map((player) {
                              final score =
                                  _playerScores[player.id!]![category];
                              return DataCell(
                                Text(score?.toString() ?? '-'),
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
