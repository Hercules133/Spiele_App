import 'package:flutter/material.dart';
import 'players_screen.dart';
import 'game_selection_screen.dart';
import 'leaderboard_screen.dart';
import 'game_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeModeChanged;

  const HomeScreen({super.key, required this.onThemeModeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiele Punkteverwaltung'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeModeChanged: onThemeModeChanged,
                  ),
                ),
              );
            },
            tooltip: 'Einstellungen',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.casino,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 48),
                _MenuButton(
                  icon: Icons.play_arrow,
                  label: 'Neues Spiel starten',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameSelectionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  icon: Icons.history,
                  label: 'Spiel-History',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameHistoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  icon: Icons.people,
                  label: 'Spieler verwalten',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  icon: Icons.leaderboard,
                  label: 'Bestenlisten',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
