import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/database_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _dbService = DatabaseService.instance;
  GameType _selectedGameType = GameType.skyjo;
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final data = await _dbService.getLeaderboard(_selectedGameType);
    setState(() {
      _leaderboardData = data;
      _isLoading = false;
    });
  }

  void _changeGameType(GameType gameType) {
    setState(() => _selectedGameType = gameType);
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestenlisten'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<GameType>(
              segments: const [
                ButtonSegment(
                  value: GameType.skyjo,
                  label: Text('Skyjo'),
                  icon: Icon(Icons.grid_4x4),
                ),
                ButtonSegment(
                  value: GameType.kniffel,
                  label: Text('Kniffel'),
                  icon: Icon(Icons.casino),
                ),
                ButtonSegment(
                  value: GameType.wizard,
                  label: Text('Wizard'),
                  icon: Icon(Icons.auto_awesome),
                ),
              ],
              selected: {_selectedGameType},
              onSelectionChanged: (Set<GameType> newSelection) {
                _changeGameType(newSelection.first);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _leaderboardData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.leaderboard_outlined,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Noch keine Spiele abgeschlossen',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Spiele ein paar Runden!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _leaderboardData.length,
                        itemBuilder: (context, index) {
                          final data = _leaderboardData[index];
                          final rank = index + 1;
                          
                          Color? medalColor;
                          if (rank == 1) medalColor = Colors.amber;
                          else if (rank == 2) medalColor = Colors.grey[400];
                          else if (rank == 3) medalColor = Colors.brown[300];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: rank <= 3 ? 4 : 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: medalColor,
                                child: Text(
                                  '$rank',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                data['player_name'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: rank <= 3
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${data['games_played']} Spiele gespielt',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '⌀ ${(data['avg_score'] as num).toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Best: ${data['best_score']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
