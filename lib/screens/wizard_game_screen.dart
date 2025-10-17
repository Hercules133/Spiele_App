import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/game.dart';
import '../models/game_player.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

class WizardGameScreen extends StatefulWidget {
  final int gameId;
  final List<Player> players;

  const WizardGameScreen({
    super.key,
    required this.gameId,
    required this.players,
  });

  @override
  State<WizardGameScreen> createState() => _WizardGameScreenState();
}

class _WizardGameScreenState extends State<WizardGameScreen> {
  final _dbService = DatabaseService.instance;
  int _currentRound = 1;
  int _maxRounds = 20;

  // Map: playerId -> round -> {prediction, actual, score}
  final Map<int, Map<int, WizardRoundData>> _roundData = {};

  bool _isLoading = true;
  bool _isPredictionPhase = true;

  @override
  void initState() {
    super.initState();
    _calculateMaxRounds();
    _initData();
    _loadGameData();
  }

  void _calculateMaxRounds() {
    final totalCards = 60;
    _maxRounds = (totalCards / widget.players.length).floor();
  }

  void _initData() {
    for (var player in widget.players) {
      _roundData[player.id!] = {};
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
          _roundData[player.id!]![score.round] = WizardRoundData(
            prediction: metadata['prediction'] as int,
            actual: metadata['actual'] as int?,
            score: score.score,
          );
        }
      }
    }

    if (_roundData.values.any((data) => data.isNotEmpty)) {
      _currentRound = _roundData.values
          .map((data) =>
              data.keys.isEmpty ? 0 : data.keys.reduce((a, b) => a > b ? a : b))
          .reduce((a, b) => a > b ? a : b);

      // Check if we're in prediction or actual phase
      final currentRoundData = _roundData.values
          .map((data) => data[_currentRound])
          .where((data) => data != null)
          .toList();

      if (currentRoundData.length == widget.players.length) {
        if (currentRoundData.any((data) => data!.actual == null)) {
          _isPredictionPhase = false;
        } else {
          _currentRound++;
          _isPredictionPhase = true;
        }
      }
    }

    setState(() => _isLoading = false);
  }

  int _getTotalScore(int playerId) {
    int total = 0;
    for (var round in _roundData[playerId]!.values) {
      total += round.score;
    }
    return total;
  }

  Future<void> _savePredictions(Map<int, int> predictions) async {
    for (var entry in predictions.entries) {
      final playerId = entry.key;
      final prediction = entry.value;

      final metadata = jsonEncode({
        'prediction': prediction,
        'actual': null,
      });

      await _dbService.createGameScore(
        GameScore(
          gameId: widget.gameId,
          playerId: playerId,
          round: _currentRound,
          score: 0, // Will be calculated later
          metadata: metadata,
        ),
      );

      _roundData[playerId]![_currentRound] = WizardRoundData(
        prediction: prediction,
        actual: null,
        score: 0,
      );
    }

    setState(() {
      _isPredictionPhase = false;
    });
  }

  Future<void> _saveActuals(Map<int, int> actuals) async {
    for (var entry in actuals.entries) {
      final playerId = entry.key;
      final actual = entry.value;
      final roundData = _roundData[playerId]![_currentRound]!;

      // Calculate score
      int score;
      if (roundData.prediction == actual) {
        score = 20 + (10 * actual);
      } else {
        score = -10 * (roundData.prediction - actual).abs();
      }

      final metadata = jsonEncode({
        'prediction': roundData.prediction,
        'actual': actual,
      });

      // Get the score record and update it
      final scores = await _dbService.getPlayerScoresForGame(
        widget.gameId,
        playerId,
      );
      final scoreRecord = scores.firstWhere(
        (s) => s.round == _currentRound && s.playerId == playerId,
      );

      await _dbService.updateGameScore(
        scoreRecord.copyWith(
          score: score,
          metadata: metadata,
        ),
      );

      _roundData[playerId]![_currentRound] = WizardRoundData(
        prediction: roundData.prediction,
        actual: actual,
        score: score,
      );
    }

    setState(() {
      if (_currentRound < _maxRounds) {
        _currentRound++;
        _isPredictionPhase = true;
      } else {
        _finishGame();
      }
    });
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

  void _showInputDialog() {
    final controllers = <int, TextEditingController>{};
    for (var player in widget.players) {
      controllers[player.id!] = TextEditingController();
    }

    String? errorText;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isPredictionPhase
                  ? 'Runde $_currentRound - Ansagen'
                  : 'Runde $_currentRound - Stiche'),
              const SizedBox(height: 4),
              Text(
                'Runde $_currentRound von $_maxRounds ($_currentRound Karten)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...widget.players.map((player) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controllers[player.id!],
                    decoration: InputDecoration(
                      labelText: player.name,
                      border: const OutlineInputBorder(),
                      hintText: _isPredictionPhase
                          ? 'Ansage (0-$_currentRound)'
                          : 'Tatsächliche Stiche (0-$_currentRound)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                );
              }).toList(),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
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
                final data = <int, int>{};
                bool allValid = true;
                for (var entry in controllers.entries) {
                  final value = int.tryParse(entry.value.text.trim());
                  if (value == null) {
                    allValid = false;
                    break;
                  }
                  data[entry.key] = value;
                }
                if (!allValid) {
                  errorText = 'Bitte alle Felder ausfüllen';
                  setState(() {});
                  return;
                }
                if (!_isPredictionPhase) {
                  final sum = data.values.reduce((a, b) => a + b);
                  if (sum != _currentRound) {
                    errorText =
                        'Die Summe der Stiche muss $_currentRound ergeben!';
                    setState(() {});
                    return;
                  }
                }
                errorText = null;
                setState(() {});
                if (_isPredictionPhase) {
                  _savePredictions(data);
                } else {
                  _saveActuals(data);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
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

    final isGameFinished = _currentRound > _maxRounds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wizard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Rundeninformation - Hervorgehoben
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.casino, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Runde $_currentRound von $_maxRounds',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentRound} Karten pro Spieler',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                // Fortschrittsbalken
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _currentRound / _maxRounds,
                    minHeight: 10,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phaseninfo
          if (!isGameFinished)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _isPredictionPhase
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]?.withOpacity(0.5)
                      : Colors.blue[100])
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange[900]?.withOpacity(0.5)
                      : Colors.orange[100]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPredictionPhase ? Icons.psychology : Icons.edit,
                    size: 20,
                    color: _isPredictionPhase
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[200]
                            : Colors.blue[900])
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[200]
                            : Colors.orange[900]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPredictionPhase
                        ? 'Phase: Stiche ansagen'
                        : 'Phase: Stiche eintragen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isPredictionPhase
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[200]
                              : Colors.blue[900])
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange[200]
                              : Colors.orange[900]),
                    ),
                  ),
                ],
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
                          'Runde',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...widget.players.map((player) {
                        return DataColumn(
                          label: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Σ ${_getTotalScore(player.id!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    rows: [
                      for (int round = 1;
                          round <= _currentRound && round <= _maxRounds;
                          round++)
                        DataRow(
                          cells: [
                            DataCell(Text('$round')),
                            ...widget.players.map((player) {
                              final data = _roundData[player.id!]![round];
                              if (data == null) {
                                return const DataCell(Text('-'));
                              }

                              String displayText;
                              if (data.actual == null) {
                                displayText = '${data.prediction}?';
                              } else {
                                displayText =
                                    '${data.prediction}/${data.actual}\n${data.score}';
                              }

                              Color? bgColor;
                              Color? textColor;
                              if (data.actual != null) {
                                final isCorrect =
                                    data.prediction == data.actual;
                                bgColor = isCorrect
                                    ? Colors.green[100]
                                    : Colors.red[100];
                                // Dunkler Text für helle Hintergründe (besserer Kontrast)
                                textColor = isCorrect
                                    ? Colors.green[900]
                                    : Colors.red[900];
                              }

                              return DataCell(
                                Container(
                                  color: bgColor,
                                  child: Center(
                                    child: Text(
                                      displayText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
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
          if (!isGameFinished)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _showInputDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  _isPredictionPhase ? 'Ansagen eingeben' : 'Stiche eingeben',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WizardRoundData {
  final int prediction;
  final int? actual;
  final int score;

  WizardRoundData({
    required this.prediction,
    this.actual,
    required this.score,
  });
}
