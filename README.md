# Spiele App

Eine Flutter-App zur Punkteverwaltung für Gesellschaftsspiele.

## Features

- **Spielerverwaltung**: Spieler anlegen, bearbeiten und verwalten
- **Unterstützte Spiele**:
  - **Skyjo**: Rundenbasierte Punkteeingabe
  - **Kniffel**: Vollständige Scorecard mit allen Kategorien
  - **Wizard**: Stichansagen und automatische Punkteberechnung
- **Bestenlisten**: Statistiken und Rankings für jedes Spiel
- **Lokale Datenspeicherung**: Alle Daten werden lokal auf dem Gerät gespeichert (SQLite)
- **Cross-Platform**: Läuft auf Android, iOS, Web, Linux und Windows

## Erste Schritte

### Voraussetzungen

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (für mobile Entwicklung)

### Installation

1. Repository klonen
```bash
git clone https://github.com/Hercules133/spiele_app.git
cd spiele_app
```

2. Dependencies installieren
```bash
flutter pub get
```

3. App starten
```bash
# Für Android/iOS
flutter run

# Für Web
flutter run -d chrome

# Für Linux Desktop
flutter run -d linux

# Für Windows Desktop
flutter run -d windows
```

## Projektstruktur

```
lib/
├── main.dart                 # App-Einstiegspunkt
├── models/                   # Datenmodelle
│   ├── player.dart
│   ├── game.dart
│   ├── game_player.dart
│   └── game_score.dart
├── services/                 # Services (z.B. Datenbank)
│   └── database_service.dart
└── screens/                  # UI Screens
    ├── home_screen.dart
    ├── players_screen.dart
    ├── game_selection_screen.dart
    ├── leaderboard_screen.dart
    ├── skyjo_game_screen.dart
    ├── kniffel_game_screen.dart
    └── wizard_game_screen.dart
```

## Verwendung

1. **Spieler hinzufügen**: Navigiere zu "Spieler verwalten" und füge Spieler hinzu
2. **Spiel starten**: 
   - Wähle "Neues Spiel starten"
   - Wähle ein Spiel (Skyjo, Kniffel oder Wizard)
   - Wähle mindestens 2 Spieler aus
   - Klicke auf "Spiel starten"
3. **Punkte eintragen**: Trage die Punkte für jede Runde/Kategorie ein
4. **Spiel beenden**: Klicke auf "Spiel beenden" um das Endergebnis zu sehen
5. **Bestenlisten**: Schaue dir die Statistiken und Rankings in "Bestenlisten" an

## Spielregeln in der App

### Skyjo
- Rundenbasierte Punkteeingabe
- Niedrigste Gesamtpunktzahl gewinnt
- Unterstützt negative Punkte

### Kniffel
- Vollständige Scorecard mit allen 13 Kategorien
- Bonus bei 63+ Punkten im oberen Teil
- Höchste Punktzahl gewinnt

### Wizard
- Stichansage vor jeder Runde
- Punkte:
  - Richtige Ansage: 20 + (10 × Stiche)
  - Falsche Ansage: -10 × Differenz
- Höchste Punktzahl gewinnt

## Technologien

- **Flutter**: UI Framework
- **SQLite**: Lokale Datenbank (via sqflite)
- **Material Design 3**: UI Design

## Zukünftige Erweiterungen

- Cloud-Synchronisation
- Weitere Spiele hinzufügen
- Erweiterte Statistiken
- Spielhistorie
- Export/Import von Daten

## Lizenz

Dieses Projekt ist für den privaten Gebrauch.

## Autor

Hercules133
