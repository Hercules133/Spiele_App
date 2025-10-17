# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.0.0] - 2025-10-17

### Hinzugefügt ✨
- **Dark Mode Support**: Heller, dunkler und System-Modus mit persistenter Speicherung
- **Spiel-History Screen**: Laufende Spiele fortsetzen und beendete Spiele einsehen
- **Einstellungsseite**: Zentrale Einstellungen mit Theme-Auswahl
- Neue Methode `getPlayersForGame()` im DatabaseService
- Settings-Button in der AppBar des Home Screens
- Spiel-History Button im Hauptmenü
- PreferencesService für Theme-Verwaltung
- Dokumentation für neue Features (`docs/NEUE_FEATURES.md`)
- Feature-Update Dokumentation (`docs/FEATURE_UPDATE.md`)

### Geändert 🔧
- Home Screen: Neue Navigation zu History und Settings
- Main App: Umstellung auf StatefulWidget für Theme-Management
- Material Design 3: Volle Dark Theme Unterstützung
- README.md: Aktualisiert mit neuen Features

### Behoben 🐛
- **Dark Mode Kontrast**: Textfarben in Wizard, Kniffel und Skyjo für bessere Lesbarkeit optimiert
  - Wizard: Dunkle Textfarben auf hellen Hintergründen (grün/rot)
  - Kniffel: Adaptive Zeilenfarben für Summen und Bonus
  - Skyjo: Theme-bewusste Schatten und Hintergründe
- Alle festen `Colors.grey[X]` durch `Theme.colorScheme.*` ersetzt
- `MaterialStateProperty` durch `WidgetStateProperty` ersetzt

### Abhängigkeiten 📦
- Hinzugefügt: `shared_preferences: ^2.2.2`

## [0.9.0] - 2025-10-17

### Hinzugefügt
- Wizard Spiellogik mit automatischer Punkteberechnung
- Skyjo mit Auto-End bei >100 Punkten
- Kniffel mit vollständiger Scorecard
- Spieler-Verwaltung
- Bestenlisten für alle Spiele
- SQLite Datenbank für lokale Speicherung
- Desktop-Support (Linux, Windows, macOS)

### Features
- Rundenbasierte Punkteeingabe für Skyjo
- Stichansagen für Wizard
- Vollständige Kniffel-Kategorien
- Material Design 3 UI
- Cross-Platform Support

## [0.1.0] - 2025-10-16

### Hinzugefügt
- Initiales Projekt-Setup
- Flutter App Grundstruktur
- Basis-Navigation
- Datenbank-Schema

---

## Geplant für zukünftige Versionen

### [1.1.0] - Geplant
- Export/Import von Spielständen
- Erweiterte Statistiken mit Diagrammen
- Spieler-Avatare
- Undo/Redo für Punkteeingaben

### [2.0.0] - Geplant
- Cloud-Synchronisation
- Multiplayer-Unterstützung
- Weitere Spiele (Phase 10, Uno, Rommé)
- Achievements System