import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;

  const SettingsScreen({super.key, required this.onThemeModeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await PreferencesService.instance.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
    });
  }

  void _changeThemeMode(ThemeMode? themeMode) {
    if (themeMode == null) return;
    setState(() {
      _currentThemeMode = themeMode;
    });
    widget.onThemeModeChanged(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Darstellung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Hell'),
            subtitle: const Text('Heller Modus'),
            value: ThemeMode.light,
            groupValue: _currentThemeMode,
            onChanged: _changeThemeMode,
            secondary: const Icon(Icons.light_mode),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dunkel'),
            subtitle: const Text('Dunkler Modus'),
            value: ThemeMode.dark,
            groupValue: _currentThemeMode,
            onChanged: _changeThemeMode,
            secondary: const Icon(Icons.dark_mode),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Folgt den Systemeinstellungen'),
            value: ThemeMode.system,
            groupValue: _currentThemeMode,
            onChanged: _changeThemeMode,
            secondary: const Icon(Icons.settings_suggest),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App-Informationen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('Entwickelt mit Flutter'),
            subtitle: Text('Eine Punkteverwaltung für Gesellschaftsspiele'),
          ),
        ],
      ),
    );
  }
}
