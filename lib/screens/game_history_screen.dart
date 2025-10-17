import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import 'skyjo_game_screen.dart';
import 'kniffel_game_screen.dart';
import 'wizard_game_screen.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  final _dbService = DatabaseService.instance;
  List<Game> _runningGames = [];
  List<Game> _completedGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final allGames = await _dbService.getAllGames();
    setState(() {
      _runningGames = allGames.where((g) => !g.isCompleted).toList();
      _completedGames = allGames.where((g) => g.isCompleted).toList();
      _isLoading = false;
    });
  }

  Future<List<Player>> _getGamePlayers(int gameId) async {
    return await _dbService.getPlayersForGame(gameId);
  }

  Future<void> _continueGame(Game game) async {
    final players = await _getGamePlayers(game.id!);

    if (!mounted) return;

    Widget gameScreen;
    switch (game.gameType) {
      case GameType.skyjo:
        gameScreen = SkyjoGameScreen(gameId: game.id!, players: players);
        break;
      case GameType.kniffel:
        gameScreen = KniffelGameScreen(gameId: game.id!, players: players);
        break;
      case GameType.wizard:
        gameScreen = WizardGameScreen(gameId: game.id!, players: players);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen),
    ).then((_) => _loadGames()); // Reload when returning
  }

  Future<void> _deleteGame(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiel löschen'),
        content: Text(
          'Möchtest du dieses ${game.gameType.displayName}-Spiel wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteGame(game.id!);
      _loadGames();
    }
  }

  Widget _buildGameCard(Game game, {required bool isRunning}) {
    return FutureBuilder<List<Player>>(
      future: _getGamePlayers(game.id!),
      builder: (context, snapshot) {
        final players = snapshot.data ?? [];
        final playerNames = players.map((p) => p.name).join(', ');

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isRunning
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                _getGameIcon(game.gameType),
                color: isRunning
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            title: Text(
              game.gameType.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerNames.isEmpty ? 'Keine Spieler' : playerNames),
                const SizedBox(height: 4),
                Text(
                  _formatDate(game.startedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (game.isCompleted && game.completedAt != null)
                  Text(
                    'Beendet: ${_formatDate(game.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRunning)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _continueGame(game),
                    tooltip: 'Fortsetzen',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteGame(game),
                  tooltip: 'Löschen',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getGameIcon(GameType gameType) {
    switch (gameType) {
      case GameType.skyjo:
        return Icons.grid_4x4;
      case GameType.kniffel:
        return Icons.casino;
      case GameType.wizard:
        return Icons.auto_awesome;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Heute ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Gestern ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays} Tagen';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel-History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.play_circle_outline),
                        text: 'Laufend (${_runningGames.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.check_circle_outline),
                        text: 'Beendet (${_completedGames.length})',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Laufende Spiele
                        _runningGames.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_esports_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Keine laufenden Spiele',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _runningGames.length,
                                itemBuilder: (context, index) => _buildGameCard(
                                  _runningGames[index],
                                  isRunning: true,
                                ),
                              ),
                        // Beendete Spiele
                        _completedGames.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Keine beendeten Spiele',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _completedGames.length,
                                itemBuilder: (context, index) => _buildGameCard(
                                  _completedGames[index],
                                  isRunning: false,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
