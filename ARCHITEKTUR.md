# App-Architektur

## Übersicht

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                            │
├─────────────────────────────────────────────────────────────┤
│  Home Screen                                                │
│     ├── Neues Spiel starten → Game Selection Screen        │
│     │                            ├── Skyjo Game Screen      │
│     │                            ├── Kniffel Game Screen    │
│     │                            └── Wizard Game Screen     │
│     ├── Spieler verwalten → Players Screen                  │
│     └── Bestenlisten → Leaderboard Screen                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Database Service                                           │
│    - CRUD Operationen für alle Models                      │
│    - Leaderboard Queries                                    │
│    - SQLite Datenbankmanagement                            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  Models:                                                    │
│    - Player (id, name, created_at)                         │
│    - Game (id, game_type, started_at, completed_at)       │
│    - GamePlayer (id, game_id, player_id, total_score)     │
│    - GameScore (id, game_id, player_id, round, score)     │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    Persistence Layer                        │
├─────────────────────────────────────────────────────────────┤
│  SQLite Database (spiele_app.db)                           │
│    Tables: players, games, game_players, game_scores       │
└─────────────────────────────────────────────────────────────┘
```

## Datenfluss

### Spiel erstellen:
1. User wählt Spiel und Spieler (Game Selection Screen)
2. Game-Eintrag wird erstellt (DatabaseService)
3. GamePlayer-Einträge werden für jeden Spieler erstellt
4. Navigation zum entsprechenden Game Screen

### Punkte erfassen:
1. User gibt Punkte ein (Game Screen)
2. GameScore-Eintrag wird erstellt
3. UI wird aktualisiert mit neuen Scores
4. Bei Spielende: Game wird als completed markiert, Totalscore wird berechnet

### Bestenlisten anzeigen:
1. User wählt Spiel (Leaderboard Screen)
2. Aggregierte Daten werden aus DB geladen (getLeaderboard)
3. Statistiken werden angezeigt (Anzahl Spiele, Durchschnitt, Best Score)

## Datenbankschema

```sql
-- Spieler Tabelle
CREATE TABLE players (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- Spiele Tabelle
CREATE TABLE games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  game_type TEXT NOT NULL,  -- 'skyjo', 'kniffel', 'wizard'
  started_at TEXT NOT NULL,
  completed_at TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0
);

-- Spieler-Spiel Zuordnung
CREATE TABLE game_players (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  game_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  player_order INTEGER NOT NULL,
  total_score INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
  FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
);

-- Spielstände pro Runde
CREATE TABLE game_scores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  game_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  round INTEGER NOT NULL,
  score INTEGER NOT NULL,
  metadata TEXT,  -- JSON für spielspezifische Daten
  FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
  FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
);
```

## Spielspezifische Logik

### Skyjo
- Rundenbasiert (beliebig viele Runden)
- Punkte können positiv oder negativ sein
- Niedrigste Gesamtpunktzahl gewinnt
- Jede Runde wird sofort gespeichert

### Kniffel
- 13 Kategorien (6 obere, 7 untere)
- Bonus bei ≥63 Punkten im oberen Teil (+35)
- Höchste Punktzahl gewinnt
- Spieler sind abwechselnd am Zug
- Metadata: `{"category": "Dreierpasch"}`

### Wizard
- Variable Rundenanzahl (abhängig von Spieleranzahl)
- 2 Phasen pro Runde: Ansage, dann tatsächliche Stiche
- Punkteberechnung:
  - Richtig: 20 + (10 × Stiche)
  - Falsch: -10 × |Differenz|
- Höchste Punktzahl gewinnt
- Metadata: `{"prediction": 3, "actual": 2}`

## State Management

Die App verwendet StatefulWidgets mit lokalem State:
- Listen werden beim initState geladen
- Bei Änderungen wird setState() aufgerufen
- Datenbank-Operationen sind async/await

## Plattform-Unterstützung

- **Android**: Native Integration via AndroidManifest.xml
- **iOS**: CocoaPods Integration via Podfile
- **Web**: Progressive Web App via manifest.json
- **Responsive**: Automatische Anpassung an Bildschirmgrößen
