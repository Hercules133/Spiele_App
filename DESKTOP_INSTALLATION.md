# Desktop Installation Guide

Diese Anleitung hilft dir, die Spiele App auf Linux und Windows Desktop zu installieren und auszuführen.

## 📋 Voraussetzungen

### Für alle Plattformen
- Flutter SDK (>=3.0.0)
- Git

### Linux (Debian/Ubuntu)
```bash
# Installiere Build-Dependencies
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsqlite3-dev
```

### Linux (Andere Distributionen)
- **Fedora/RHEL:**
  ```bash
  sudo dnf install clang cmake ninja-build gtk3-devel
  ```
- **Arch Linux:**
  ```bash
  sudo pacman -S clang cmake ninja gtk3
  ```

### Windows
- **Visual Studio 2022** (oder neuer) mit "Desktop development with C++" Workload
- Alternativ: **Visual Studio Build Tools 2022** mit C++ build tools

## 🚀 Installation

### 1. Flutter installieren

#### Linux:
```bash
# Via Snap (empfohlen)
sudo snap install flutter --classic

# Flutter validieren
flutter doctor
```

#### Windows:
1. Lade Flutter von https://docs.flutter.dev/get-started/install/windows herunter
2. Entpacke das ZIP in einen Ordner (z.B. `C:\src\flutter`)
3. Füge `C:\src\flutter\bin` zu deinem PATH hinzu
4. Öffne eine neue Command Prompt und führe aus:
```cmd
flutter doctor
```

### 2. Desktop Support aktivieren

```bash
# Linux
flutter config --enable-linux-desktop

# Windows
flutter config --enable-windows-desktop

# Verifizieren
flutter devices
```

Du solltest jetzt "Linux" oder "Windows" in der Liste der verfügbaren Geräte sehen.

### 3. Projekt klonen und Dependencies installieren

```bash
cd /path/to/your/projects
git clone https://github.com/Hercules133/spiele_app.git
cd spiele_app
flutter pub get
```

**Hinweis:** Die App verwendet `sqflite_common_ffi` für Desktop-Datenbankunterstützung. Dies wird automatisch mit `flutter pub get` installiert.

## 🎮 App ausführen

### Linux:
```bash
flutter run -d linux
```

Beim ersten Start wird die App kompiliert, das kann einige Minuten dauern.

### Windows:
```bash
flutter run -d windows
```

## 🔨 App bauen (Release Build)

### Linux:
```bash
flutter build linux --release
```

Die fertige App findest du in:
```
build/linux/x64/release/bundle/
```

Das `bundle` Verzeichnis enthält alle notwendigen Dateien. Du kannst es an einen anderen Ort kopieren oder als ZIP verteilen.

### Windows:
```bash
flutter build windows --release
```

Die fertige App findest du in:
```
build\windows\runner\Release\
```

## 📦 App Distribution

### Linux (.deb Paket erstellen)

Für Ubuntu/Debian kannst du ein .deb Paket erstellen:

```bash
# Installiere flutter_distributor
dart pub global activate flutter_distributor

# Erstelle .deb Paket
flutter_distributor package --platform linux --targets deb
```

### Windows (Installer erstellen)

Für Windows kannst du Inno Setup verwenden:

1. Installiere [Inno Setup](https://jrsoftware.org/isinfo.php)
2. Erstelle ein Installer-Script (siehe Beispiel unten)
3. Kompiliere den Installer

**Beispiel Inno Setup Script (`installer.iss`):**
```iss
[Setup]
AppName=Spiele App
AppVersion=1.0.0
DefaultDirName={pf}\SpieleApp
DefaultGroupName=Spiele App
OutputBaseFilename=SpieleAppSetup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Spiele App"; Filename: "{app}\spiele_app.exe"
Name: "{commondesktop}\Spiele App"; Filename: "{app}\spiele_app.exe"
```

## 🐛 Troubleshooting

### Linux

#### Problem: "databaseFactory not initialized" oder "Failed to load dynamic library 'libsqlite3.so'"
**Lösung:** SQLite3-Bibliothek fehlt
```bash
sudo apt-get install libsqlite3-dev
```

#### Problem: "libgtk-3.so.0: cannot open shared object file"
**Lösung:**
```bash
sudo apt-get install libgtk-3-0
```

#### Problem: "GLIBCXX_3.4.XX not found"
**Lösung:**
```bash
sudo apt-get install libstdc++6
```

#### Problem: App-Fenster ist zu klein/groß
**Lösung:** Ändere die Fenstergröße in `linux/runner/my_application.cc` (Zeile 46):
```cpp
gtk_window_set_default_size(window, 1280, 720);  // Ändere diese Werte
```

### Windows

#### Problem: "VCRUNTIME140.dll not found"
**Lösung:** Installiere [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

#### Problem: "CMake not found"
**Lösung:** Installiere Visual Studio mit "Desktop development with C++" Workload

#### Problem: Build-Fehler mit "MSBuild"
**Lösung:** Stelle sicher, dass Visual Studio 2022 oder Build Tools installiert sind:
```cmd
flutter doctor -v
```

#### Problem: App startet nicht im Debug-Modus
**Lösung:** Verwende den Release-Modus:
```cmd
flutter run -d windows --release
```

## ⚙️ Konfiguration

### App-Icon ändern

#### Linux:
Ersetze die Icon-Datei (sollte erstellt werden):
```
linux/runner/resources/app_icon.png
```

#### Windows:
Ersetze die Icon-Datei:
```
windows/runner/resources/app_icon.ico
```

### App-Name ändern

#### Linux:
In `linux/runner/my_application.cc`:
```cpp
gtk_header_bar_set_title(header_bar, "Dein App Name");
gtk_window_set_title(window, "Dein App Name");
```

#### Windows:
In `windows/runner/main.cpp`:
```cpp
if (!window.Create(L"Dein App Name", origin, size)) {
```

## 🎯 Performance-Tipps

### Linux
- Verwende Release-Builds für bessere Performance
- Bei älteren Systemen: Reduziere Animationen

### Windows
- Release-Builds sind deutlich schneller als Debug
- Bei Performance-Problemen: Deaktiviere Windows Defender für den App-Ordner (während der Entwicklung)

## 📱 Desktop vs Mobile Unterschiede

Die App ist responsive und passt sich automatisch an:
- **Desktop**: Größere Fenster, Maus-optimierte Bedienung
- **Mobile**: Touch-optimiert, kleinerer Bildschirm

Alle Features sind auf Desktop und Mobile identisch verfügbar.

## 🔄 Updates

Um die App zu aktualisieren:

```bash
cd Spiele_App
git pull origin main
flutter pub get
flutter run -d [linux|windows]
```

## 📞 Support

Bei Problemen:
1. Prüfe `flutter doctor` Output
2. Schaue in die [FAQ.md](FAQ.md)
3. Erstelle ein Issue auf GitHub

---

**Viel Spaß beim Spielen! 🎮**
