# FAQ - Häufig gestellte Fragen

## Installation & Setup

### Q: Wie installiere ich Flutter?
**A:** Auf Linux:
```bash
sudo snap install flutter --classic
flutter doctor
```
Für andere Betriebssysteme siehe: https://docs.flutter.dev/get-started/install

### Q: Die App startet nicht. Was kann ich tun?
**A:** Prüfe folgendes:
1. Ist Flutter installiert? → `flutter --version`
2. Sind die Dependencies installiert? → `flutter pub get`
3. Ist ein Gerät verbunden? → `flutter devices`
4. Gibt es Fehler? → `flutter doctor`

### Q: Kann ich die App auch ohne Android Studio nutzen?
**A:** Ja! Du kannst die App im Browser testen:
```bash
flutter run -d chrome
```

## Nutzung

### Q: Wie füge ich einen neuen Spieler hinzu?
**A:** 
1. Öffne die App
2. Tippe auf "Spieler verwalten"
3. Drücke auf den "+" Button
4. Gib den Namen ein und speichere

### Q: Kann ich ein Spiel später fortsetzen?
**A:** In der aktuellen Version (v1.0) nicht. Spiele müssen in einer Sitzung beendet werden. Dieses Feature ist für v1.1 geplant (siehe TODO.md).

### Q: Wie lösche ich einen Spieler?
**A:** 
1. Gehe zu "Spieler verwalten"
2. Tippe auf das Papierkorb-Icon neben dem Spieler
3. Bestätige das Löschen

### Q: Werden meine Daten gesichert?
**A:** Ja, alle Daten werden lokal auf deinem Gerät gespeichert (SQLite Datenbank). Ein Cloud-Backup ist für v2.0 geplant.

## Spielregeln

### Q: Wie funktioniert die Punktevergabe bei Skyjo?
**A:** 
- Jede Runde trägt ihr eigene Punkte ein
- Die Punkte werden addiert
- Niedrigste Gesamtpunktzahl gewinnt
- Negative Punkte sind möglich

### Q: Was ist der Bonus bei Kniffel?
**A:** Wenn du im oberen Teil (Einser bis Sechser) mindestens 63 Punkte erreichst, bekommst du 35 Bonuspunkte.

### Q: Wie werden Punkte bei Wizard berechnet?
**A:** 
- Richtige Ansage: 20 Punkte + (10 × Anzahl der angesagten Stiche)
- Falsche Ansage: -10 Punkte × Differenz zwischen Ansage und tatsächlichen Stichen
- Beispiel: Ansage 3, bekommen 2 → -10 Punkte
- Beispiel: Ansage 2, bekommen 2 → 20 + 20 = 40 Punkte

### Q: Wie viele Runden hat Wizard?
**A:** Die Anzahl der Runden wird automatisch berechnet: 60 Karten ÷ Anzahl Spieler = Max. Runden

## Bestenlisten

### Q: Warum erscheint ein Spieler nicht in der Bestenliste?
**A:** Bestenlisten zeigen nur:
- Abgeschlossene Spiele (mit "Spiel beenden" beendet)
- Spieler die mindestens ein Spiel abgeschlossen haben

### Q: Was bedeutet "⌀" in den Bestenlisten?
**A:** Das ist das Durchschnittszeichen (Average). Es zeigt die durchschnittliche Punktzahl über alle Spiele.

### Q: Warum bin ich auf Platz 1 bei Skyjo, obwohl ich weniger Punkte habe?
**A:** Bei Skyjo gewinnt die niedrigste Punktzahl! Weniger ist besser.

## Technische Fragen

### Q: Auf welchen Geräten läuft die App?
**A:** 
- Android Smartphones & Tablets (ab Android 5.0/API 21)
- iOS iPhones & iPads (ab iOS 12.0)
- Webbrowser (Chrome, Firefox, Safari, Edge)
- Linux Desktop (Debian/Ubuntu und andere)
- Windows Desktop (Windows 7 und neuer)

### Q: Wie viel Speicherplatz benötigt die App?
**A:** 
- Android: ~20-30 MB
- iOS: ~25-35 MB
- Web: Lädt bei Bedarf (~5 MB Download)
- Linux Desktop: ~30-40 MB
- Windows Desktop: ~35-45 MB

### Q: Werden meine Daten synchronisiert zwischen Geräten?
**A:** Nicht in v1.0. Jedes Gerät hat seine eigene lokale Datenbank. Cloud-Sync ist für v2.0 geplant.

### Q: Kann ich meine Daten exportieren?
**A:** Noch nicht in v1.0, aber geplant für v1.1 (CSV/JSON Export).

### Q: Ist die App Open Source?
**A:** Ja! Der Quellcode ist auf GitHub verfügbar: https://github.com/Hercules133/Spiele_App

## Probleme & Fehler

### Q: Die App stürzt ab. Was kann ich tun?
**A:** 
1. Starte die App neu
2. Lösche den App-Cache (Android Settings → Apps → Spiele App → Speicher → Cache leeren)
3. Erstelle ein Issue auf GitHub mit Details

### Q: Ich habe versehentlich falsche Punkte eingetragen. Kann ich sie ändern?
**A:** In v1.0 nicht direkt. Du kannst:
- Das Spiel neu starten
- Oder warten auf v1.1 mit Undo-Funktion

### Q: Die Bestenliste zeigt falsche Werte an
**A:** 
1. Stelle sicher, dass das Spiel mit "Spiel beenden" abgeschlossen wurde
2. Starte die App neu
3. Falls das Problem weiterhin besteht, melde es auf GitHub

## Entwicklung & Beitrag

### Q: Kann ich bei der Entwicklung helfen?
**A:** Ja, gerne! 
1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Mache deine Änderungen
4. Erstelle einen Pull Request

### Q: Wie kann ich ein neues Spiel vorschlagen?
**A:** Erstelle ein Issue auf GitHub mit:
- Name des Spiels
- Kurze Regelerklärung
- Wie die Punkte erfasst werden sollten

### Q: Wo finde ich die Dokumentation für Entwickler?
**A:** Siehe:
- `ARCHITEKTUR.md` - App-Architektur
- `TODO.md` - Geplante Features
- Code-Kommentare in den `.dart` Dateien

## Kontakt

### Q: Wo kann ich Fehler melden?
**A:** Auf GitHub: https://github.com/Hercules133/Spiele_App/issues

### Q: Wo kann ich Feature-Requests einreichen?
**A:** Ebenfalls auf GitHub Issues mit dem Label "enhancement"

### Q: Gibt es eine Community?
**A:** Geplant für die Zukunft (Discord-Server, siehe TODO.md)

---

**Weitere Fragen?** Erstelle ein Issue auf GitHub oder schau in die anderen Dokumentations-Dateien!
