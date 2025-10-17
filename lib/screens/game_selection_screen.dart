import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/game_player.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import 'skyjo_game_screen.dart';
import 'kniffel_game_screen.dart';
import 'wizard_game_screen.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  final _dbService = DatabaseService.instance;
  GameType? _selectedGameType;
  List<Player> _allPlayers = [];
  List<Player> _selectedPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await _dbService.getAllPlayers();
    setState(() {
      _allPlayers = players;
      _isLoading = false;
    });
  }

  void _togglePlayerSelection(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        _selectedPlayers.add(player);
      }
    });
  }

  Future<void> _startGame() async {
    if (_selectedGameType == null || _selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle ein Spiel und mindestens 2 Spieler aus'),
        ),
      );
      return;
    }

    // Create game
    final game = Game(gameType: _selectedGameType!);
    final gameId = await _dbService.createGame(game);

    // Add players to game
    for (int i = 0; i < _selectedPlayers.length; i++) {
      await _dbService.createGamePlayer(
        GamePlayer(
          gameId: gameId,
          playerId: _selectedPlayers[i].id!,
          playerOrder: i,
        ),
      );
    }

    if (!mounted) return;

    // Navigate to appropriate game screen
    Widget gameScreen;
    switch (_selectedGameType!) {
      case GameType.skyjo:
        gameScreen = SkyjoGameScreen(
          gameId: gameId,
          players: _selectedPlayers,
        );
        break;
      case GameType.kniffel:
        gameScreen = KniffelGameScreen(
          gameId: gameId,
          players: _selectedPlayers,
        );
        break;
      case GameType.wizard:
        gameScreen = WizardGameScreen(
          gameId: gameId,
          players: _selectedPlayers,
        );
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => gameScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel auswählen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allPlayers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Keine Spieler vorhanden',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Füge zuerst Spieler hinzu',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Wähle ein Spiel:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GameTypeCard(
                        gameType: GameType.skyjo,
                        isSelected: _selectedGameType == GameType.skyjo,
                        onTap: () =>
                            setState(() => _selectedGameType = GameType.skyjo),
                      ),
                      const SizedBox(height: 12),
                      _GameTypeCard(
                        gameType: GameType.kniffel,
                        isSelected: _selectedGameType == GameType.kniffel,
                        onTap: () => setState(
                            () => _selectedGameType = GameType.kniffel),
                      ),
                      const SizedBox(height: 12),
                      _GameTypeCard(
                        gameType: GameType.wizard,
                        isSelected: _selectedGameType == GameType.wizard,
                        onTap: () =>
                            setState(() => _selectedGameType = GameType.wizard),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Wähle Spieler (mind. 2):',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._allPlayers.map((player) {
                        final isSelected = _selectedPlayers.contains(player);
                        return CheckboxListTile(
                          title: Text(player.name),
                          value: isSelected,
                          onChanged: (value) => _togglePlayerSelection(player),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        );
                      }),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Spiel starten',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _GameTypeCard extends StatelessWidget {
  final GameType gameType;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.gameType,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (gameType) {
      case GameType.skyjo:
        return Icons.grid_4x4;
      case GameType.kniffel:
        return Icons.casino;
      case GameType.wizard:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                _getIcon(),
                size: 40,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: 16),
              Text(
                gameType.displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
