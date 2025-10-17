# Schnellstart-Anleitung

## 1. Flutter installieren

Falls Flutter noch nicht installiert ist:

```bash
sudo snap install flutter --classic
flutter doctor
```

## 2. Projekt einrichten

```bash
cd ~/git/spiele_app
./setup.fish
```

Oder manuell:
```bash
flutter pub get
```

## 3. App starten

### Auf Android-Gerät/Emulator:
```bash
flutter run
```

### Im Browser (Web):
```bash
flutter run -d chrome
```

### Auf iOS (nur auf macOS):
```bash
flutter run -d ios
```

### Auf Linux Desktop:
```bash
flutter run -d linux
```

### Auf Windows Desktop:
```bash
flutter run -d windows
```

## 4. Verfügbare Geräte anzeigen
```bash
flutter devices
```

## Erste Schritte in der App

1. **Spieler anlegen**: Gehe zu "Spieler verwalten" und füge deine Familie/Freunde hinzu
2. **Spiel starten**: Wähle "Neues Spiel starten", dann ein Spiel und die Mitspieler
3. **Punkte eintragen**: Je nach Spiel werden die Punkte unterschiedlich erfasst
4. **Bestenlisten**: Schaue dir an, wer am besten abschneidet!

## Tipps

- Die App speichert alle Daten lokal auf deinem Gerät
- Du kannst mehrere Spiele gleichzeitig laufen haben
- Die Bestenlisten zeigen nur abgeschlossene Spiele
- Bei Skyjo: Niedrigste Punktzahl gewinnt!
- Bei Kniffel & Wizard: Höchste Punktzahl gewinnt!

## Troubleshooting

### "Flutter SDK not found"
- Stelle sicher, dass Flutter installiert ist: `flutter --version`
- Führe `flutter doctor` aus, um Probleme zu identifizieren

### App startet nicht
- Prüfe ob ein Gerät verbunden ist: `flutter devices`
- Für Web: Chrome muss installiert sein
- Für Android: USB-Debugging muss aktiviert sein
- Für Linux: GTK3 Development Libraries müssen installiert sein
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```
- Für Windows: Visual Studio mit C++ Desktop Development muss installiert sein

### Dependencies-Fehler
- Führe erneut aus: `flutter pub get`
- Lösche den Cache: `flutter clean && flutter pub get`

## Weitere Informationen

Siehe [README.md](README.md) für eine vollständige Dokumentation.
