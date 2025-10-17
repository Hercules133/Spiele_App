# Spiele App - Windows Setup Script

Write-Host "🎮 Spiele App Setup" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
$flutterExists = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterExists) {
    Write-Host "❌ Flutter ist nicht installiert!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Bitte installiere Flutter:" -ForegroundColor Yellow
    Write-Host "  1. Lade Flutter von https://docs.flutter.dev/get-started/install/windows herunter"
    Write-Host "  2. Entpacke das ZIP"
    Write-Host "  3. Füge Flutter\bin zu deinem PATH hinzu"
    Write-Host ""
    exit 1
}

Write-Host "✅ Flutter gefunden: " -ForegroundColor Green -NoNewline
flutter --version | Select-Object -First 1
Write-Host ""

# Check for Visual Studio
Write-Host "🪟 Windows erkannt - Prüfe Build Tools..."
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsWhere) {
    $vsInstances = & $vsWhere -products * -requires Microsoft.VisualStudio.Workload.NativeDesktop -format json | ConvertFrom-Json
    if ($vsInstances) {
        Write-Host "✅ Visual Studio mit C++ Desktop Development gefunden" -ForegroundColor Green
        
        # Enable Windows desktop
        flutter config --enable-windows-desktop | Out-Null
    } else {
        Write-Host "⚠️  Visual Studio C++ Desktop Development nicht gefunden!" -ForegroundColor Yellow
        Write-Host "Installiere Visual Studio mit 'Desktop development with C++' Workload"
        Write-Host "Oder installiere die Build Tools: https://visualstudio.microsoft.com/downloads/"
        Write-Host ""
    }
} else {
    Write-Host "⚠️  Visual Studio nicht gefunden!" -ForegroundColor Yellow
    Write-Host "Für Windows Desktop-Builds benötigst du Visual Studio 2022"
    Write-Host ""
}

# Get dependencies
Write-Host ""
Write-Host "📦 Installiere Flutter Dependencies..." -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies installiert" -ForegroundColor Green
} else {
    Write-Host "❌ Fehler beim Installieren der Dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Setup abgeschlossen!" -ForegroundColor Green
Write-Host ""
Write-Host "Verfügbare Befehle:" -ForegroundColor Cyan
Write-Host "  flutter run                # App auf angeschlossenem Gerät starten"
Write-Host "  flutter run -d chrome      # App im Browser starten"
Write-Host "  flutter run -d windows     # App als Windows Desktop-App starten"
Write-Host "  flutter devices            # Verfügbare Geräte anzeigen"
Write-Host "  flutter doctor             # Flutter Installation prüfen"
Write-Host ""
Write-Host "📖 Weitere Infos:" -ForegroundColor Cyan
Write-Host "  README.md                  # Vollständige Dokumentation"
Write-Host "  SCHNELLSTART.md            # Quick-Start Guide"
Write-Host "  DESKTOP_INSTALLATION.md    # Desktop-spezifische Anleitung"
Write-Host ""
