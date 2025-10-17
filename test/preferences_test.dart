import 'package:flutter_test/flutter_test.dart';
import 'package:spiele_app/services/preferences_service.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesService', () {
    test('Default theme mode is system', () async {
      final prefs = PreferencesService.instance;
      final themeMode = await prefs.getThemeMode();
      expect(themeMode, ThemeMode.system);
    });

    test('Can set and get light theme', () async {
      final prefs = PreferencesService.instance;
      await prefs.setThemeMode(ThemeMode.light);
      final themeMode = await prefs.getThemeMode();
      expect(themeMode, ThemeMode.light);
    });

    test('Can set and get dark theme', () async {
      final prefs = PreferencesService.instance;
      await prefs.setThemeMode(ThemeMode.dark);
      final themeMode = await prefs.getThemeMode();
      expect(themeMode, ThemeMode.dark);
    });

    test('Can reset to system theme', () async {
      final prefs = PreferencesService.instance;
      await prefs.setThemeMode(ThemeMode.system);
      final themeMode = await prefs.getThemeMode();
      expect(themeMode, ThemeMode.system);
    });
  });
}
