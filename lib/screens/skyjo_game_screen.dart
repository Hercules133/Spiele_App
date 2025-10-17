import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/game_player.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

class SkyjoGameScreen extends StatefulWidget {
  final int gameId;
  final List<Player> players;

  const SkyjoGameScreen({
    super.key,
    required this.gameId,
    required this.players,
  });

  @override
  State<SkyjoGameScreen> createState() => _SkyjoGameScreenState();
}

class _SkyjoGameScreenState extends State<SkyjoGameScreen> {
  final _dbService = DatabaseService.instance;
  final Map<int, List<int>> _roundScores =
      {}; // playerId -> list of round scores
  int _currentRound = 1;
  final Map<int, TextEditingController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadGameData();
  }

  void _initControllers() {
    for (var player in widget.players) {
      _controllers[player.id!] = TextEditingController();
      _roundScores[player.id!] = [];
    }
  }

  Future<void> _loadGameData() async {
    setState(() => _isLoading = true);

    for (var player in widget.players) {
      final scores = await _dbService.getPlayerScoresForGame(
        widget.gameId,
        player.id!,
      );
      _roundScores[player.id!] = scores.map((s) => s.score).toList();
    }

    if (_roundScores.values.any((scores) => scores.isNotEmpty)) {
      _currentRound = _roundScores.values
              .map((scores) => scores.length)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    setState(() => _isLoading = false);
  }

  int _getTotalScore(int playerId) {
    return _roundScores[playerId]?.fold<int>(0, (sum, score) => sum + score) ??
        0;
  }

  Future<void> _saveRound() async {
    // Validate all inputs
    for (var player in widget.players) {
      final text = _controllers[player.id!]!.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bitte gib für alle Spieler Punkte ein'),
          ),
        );
        return;
      }
    }

    // Save scores
    bool gameOver = false;
    for (var player in widget.players) {
      final score = int.parse(_controllers[player.id!]!.text.trim());
      await _dbService.createGameScore(
        GameScore(
          gameId: widget.gameId,
          playerId: player.id!,
          round: _currentRound,
          score: score,
        ),
      );
      _roundScores[player.id!]!.add(score);
      _controllers[player.id!]!.clear();
      // Prüfe ob ein Spieler über 100 Punkte hat
      if (_getTotalScore(player.id!) > 100) {
        gameOver = true;
      }
    }

    setState(() {
      _currentRound++;
    });

    if (!mounted) return;
    if (gameOver) {
      await _finishGame();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Runde gespeichert!')),
      );
    }
  }

  Future<void> _finishGame() async {
    // Update game as completed
    final game = await _dbService.getGame(widget.gameId);
    if (game != null) {
      await _dbService.updateGame(
        game.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );

      // Update total scores for each player
      final gamePlayers = await _dbService.getGamePlayers(widget.gameId);
      for (var gamePlayer in gamePlayers) {
        final totalScore = _getTotalScore(gamePlayer.playerId);
        await _dbService.updateGamePlayer(
          gamePlayer.copyWith(totalScore: totalScore),
        );
      }
    }

    if (!mounted) return;

    // Show final results
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final sortedPlayers = [...widget.players];
        sortedPlayers.sort(
            (a, b) => _getTotalScore(a.id!).compareTo(_getTotalScore(b.id!)));

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
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to home
              },
              child: const Text('Zurück zum Hauptmenü'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Skyjo - Runde $_currentRound'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Score table
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
                          'Runde',
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
                      // Previous rounds
                      for (int round = 1; round < _currentRound; round++)
                        DataRow(
                          cells: [
                            DataCell(Text('$round')),
                            ...widget.players.map((player) {
                              final scores = _roundScores[player.id!]!;
                              final score = round <= scores.length
                                  ? scores[round - 1]
                                  : 0;
                              return DataCell(Text('$score'));
                            }),
                          ],
                        ),
                      // Total row
                      DataRow(
                        color:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          return Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber[900]?.withOpacity(0.3)
                              : Colors.amber[100];
                        }),
                        cells: [
                          DataCell(
                            Text(
                              'Gesamt',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.amber[200]
                                    : Colors.amber[900],
                              ),
                            ),
                          ),
                          ...widget.players.map((player) {
                            final total = _getTotalScore(player.id!);
                            return DataCell(
                              Text(
                                '$total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.amber[200]
                                      : Colors.amber[900],
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
          // Input section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Runde $_currentRound eingeben:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.players.map((player) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllers[player.id!],
                      decoration: InputDecoration(
                        labelText: player.name,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveRound,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Runde speichern'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _finishGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Spiel beenden'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
