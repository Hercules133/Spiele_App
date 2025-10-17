#!/usr/bin/env fish

# Spiele App - Setup Script

echo "🎮 Spiele App Setup"
echo "===================="
echo ""

# Check if Flutter is installed
if not type -q flutter
    echo "❌ Flutter ist nicht installiert!"
    echo ""
    echo "Bitte installiere Flutter:"
    echo "  sudo snap install flutter --classic"
    echo ""
    echo "Oder folge der Anleitung auf: https://docs.flutter.dev/get-started/install/linux"
    exit 1
end

echo "✅ Flutter gefunden: "(flutter --version | head -n 1)
echo ""

# Check for Linux desktop dependencies
if test (uname) = "Linux"
    echo "🐧 Linux erkannt - Prüfe Desktop Dependencies..."
    
    if not type -q pkg-config
        echo "⚠️  pkg-config nicht gefunden!"
        echo "Installiere Linux Desktop Dependencies mit:"
        echo "  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev"
        echo ""
    else if not pkg-config --exists gtk+-3.0
        echo "⚠️  GTK3 nicht gefunden!"
        echo "Installiere Linux Desktop Dependencies mit:"
        echo "  sudo apt-get install libgtk-3-dev"
        echo ""
    else
        echo "✅ Linux Desktop Dependencies vorhanden"
        
        # Enable Linux desktop
        flutter config --enable-linux-desktop > /dev/null 2>&1
        
        # Check for SQLite3 (required for sqflite_common_ffi)
        if not type -q sqlite3; or not test -f /usr/lib/x86_64-linux-gnu/libsqlite3.so
            echo "⚠️  SQLite3 nicht gefunden (wird für Desktop-Datenbank benötigt)!"
            echo "Installiere SQLite3 mit:"
            echo "  sudo apt-get install libsqlite3-dev"
            echo ""
        else
            echo "✅ SQLite3 vorhanden"
        end
    end
end

# Get dependencies
echo ""
echo "📦 Installiere Flutter Dependencies..."
flutter pub get

if test $status -eq 0
    echo "✅ Dependencies installiert"
else
    echo "❌ Fehler beim Installieren der Dependencies"
    exit 1
end

echo ""
echo "🎉 Setup abgeschlossen!"
echo ""
echo "Verfügbare Befehle:"
echo "  flutter run               # App auf angeschlossenem Gerät starten"
echo "  flutter run -d chrome     # App im Browser starten"
echo "  flutter run -d linux      # App als Linux Desktop-App starten"
echo "  flutter devices           # Verfügbare Geräte anzeigen"
echo "  flutter doctor            # Flutter Installation prüfen"
echo ""
echo "📖 Weitere Infos:"
echo "  README.md                 # Vollständige Dokumentation"
echo "  SCHNELLSTART.md           # Quick-Start Guide"
echo "  DESKTOP_INSTALLATION.md   # Desktop-spezifische Anleitung"
echo ""
