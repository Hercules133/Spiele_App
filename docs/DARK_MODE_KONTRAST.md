# Dark Mode Kontrast-Verbesserungen

## Problem
Im Dark Mode waren hervorgehobene Texte in den Spiel-Screens schwer lesbar, da helle Textfarben auf hellen Hintergründen verwendet wurden.

## Lösung
Alle Farben wurden auf Theme-bewusste Farben umgestellt, die sich automatisch an Light/Dark Mode anpassen.

---

## Geänderte Dateien

### 1. `lib/screens/wizard_game_screen.dart`

**Probleme behoben:**
- ❌ `Colors.grey[600]` → ✅ `Theme.of(context).colorScheme.onSurfaceVariant`
- ❌ `Colors.grey[700]` → ✅ `Theme.of(context).colorScheme.onSurfaceVariant`
- ❌ `Colors.grey[300]` (Progressbar) → ✅ `Theme.of(context).colorScheme.surfaceContainerHighest`
- ❌ Helle Textfarbe auf `Colors.green[100]`/`Colors.red[100]` → ✅ Dunkle Textfarbe (`Colors.green[900]`/`Colors.red[900]`)
- ❌ **Phasen-Banner**: `Colors.blue[100]`/`Colors.orange[100]` mit Standard-Textfarbe → ✅ Adaptive Farben mit kontrastreichem Text
  - Light Mode: `Colors.blue[100]` Hintergrund + `Colors.blue[900]` Text  
  - Dark Mode: `Colors.blue[900]?.withOpacity(0.5)` Hintergrund + `Colors.blue[200]` Text

**Spezifische Änderungen:**
```dart
// Vorher: Heller Text auf hellem Hintergrund (schlecht im Dark Mode)
Text(displayText, textAlign: TextAlign.center)

// Nachher: Dunkler Text für besseren Kontrast
Text(
  displayText,
  textAlign: TextAlign.center,
  style: TextStyle(
    color: isCorrect ? Colors.green[900] : Colors.red[900],
  ),
)
```

### 2. `lib/screens/kniffel_game_screen.dart`

**Probleme behoben:**
- ❌ `Colors.blue[50]` (Obere/Untere Summe) → ✅ Dark Mode: `Colors.blue[900]?.withOpacity(0.3)`, Light Mode: `Colors.blue[50]`
- ❌ `Colors.green[50]` (Bonus) → ✅ Dark Mode: `Colors.green[900]?.withOpacity(0.3)`, Light Mode: `Colors.green[50]`
- ❌ `Colors.amber[100]` (Gesamt) → ✅ Dark Mode: `Colors.amber[900]?.withOpacity(0.3)`, Light Mode: `Colors.amber[100]`
- ❌ `Colors.green` (Bonus-Text) → ✅ Dark Mode: `Colors.green[300]`, Light Mode: `Colors.green[700]`

**Spezifische Änderungen:**
```dart
// Vorher: Feste helle Farbe (schlecht im Dark Mode)
color: MaterialStateProperty.all(Colors.green[50])

// Nachher: Adaptive Farbe basierend auf Theme
color: WidgetStateProperty.resolveWith<Color?>((states) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.green[900]?.withOpacity(0.3)
      : Colors.green[50];
})
```

### 3. `lib/screens/skyjo_game_screen.dart`

**Probleme behoben:**
- ❌ `Colors.black.withOpacity(0.1)` (Schatten) → ✅ `Theme.of(context).colorScheme.shadow.withOpacity(0.1)`
- ❌ `Theme.of(context).colorScheme.surfaceVariant` → ✅ `Theme.of(context).colorScheme.surfaceContainerHighest`
- ❌ **Gesamt-Zeile**: `Colors.amber[100]` mit Standard-Textfarbe → ✅ Adaptive Farben mit kontrastreichem Text
  - Light Mode: `Colors.amber[100]` Hintergrund + `Colors.amber[900]` Text
  - Dark Mode: `Colors.amber[900]?.withOpacity(0.3)` Hintergrund + `Colors.amber[200]` Text

---

## Prinzipien für besseren Dark Mode Kontrast

### 1. **Theme-bewusste Farben verwenden**
```dart
// ❌ Schlecht
color: Colors.grey[600]

// ✅ Gut
color: Theme.of(context).colorScheme.onSurfaceVariant
```

### 2. **Hintergrundfarben anpassen**
```dart
// ❌ Schlecht: Feste Farbe
backgroundColor: Colors.green[100]

// ✅ Gut: Adaptive Farbe
backgroundColor: Theme.of(context).brightness == Brightness.dark
    ? Colors.green[900]?.withOpacity(0.3)
    : Colors.green[100]
```

### 3. **Textfarben auf Hintergrund abstimmen**
```dart
// ❌ Schlecht: Heller Text auf hellem Hintergrund
Container(
  color: Colors.green[100],
  child: Text('Text') // verwendet Theme-Textfarbe (hell im Dark Mode!)
)

// ✅ Gut: Dunkler Text auf hellem Hintergrund
Container(
  color: Colors.green[100],
  child: Text(
    'Text',
    style: TextStyle(color: Colors.green[900]) // immer guter Kontrast
  )
)
```

### 4. **WidgetStateProperty statt MaterialStateProperty**
```dart
// ❌ Veraltet
color: MaterialStateProperty.all(Colors.blue[50])

// ✅ Modern und adaptive
color: WidgetStateProperty.resolveWith<Color?>((states) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.blue[900]?.withOpacity(0.3)
      : Colors.blue[50];
})
```

---

## Farb-Mapping für Dark Mode

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Subtitel/Beschreibung | `Colors.grey[600]` | `onSurfaceVariant` |
| Progressbar Hintergrund | `Colors.grey[300]` | `surfaceContainerHighest` |
| Erfolg Hintergrund | `Colors.green[100]` | `Colors.green[900]?.withOpacity(0.3)` |
| Erfolg Text | `Colors.green[900]` | `Colors.green[900]` |
| Fehler Hintergrund | `Colors.red[100]` | `Colors.red[900]?.withOpacity(0.3)` |
| Fehler Text | `Colors.red[900]` | `Colors.red[900]` |
| Info Hintergrund | `Colors.blue[50]` | `Colors.blue[900]?.withOpacity(0.3)` |
| Hervorhebung | `Colors.amber[100]` | `Colors.amber[900]?.withOpacity(0.3)` |
| Bonus Text | `Colors.green[700]` | `Colors.green[300]` |

---

## Testergebnisse

### ✅ Wizard Game Screen
- Rundenanzeige: Gut lesbar in beiden Modi
- Progressbar: Guter Kontrast
- Tabellenzellen (grün/rot): Dunkler Text, perfekt lesbar
- **Phasen-Banner**: "Phase: Stiche ansagen" jetzt mit dunklem Text auf hellem Hintergrund (Light) bzw. hellem Text auf dunklem Hintergrund (Dark)

### ✅ Kniffel Game Screen
- Summenzeilen (blau): Guter Kontrast in beiden Modi
- Bonuszeile (grün): Text gut lesbar
- Gesamtzeile (gelb): Hervorgehoben und lesbar

### ✅ Skyjo Game Screen
- Eingabebereich: Guter Kontrast zum Hintergrund
- Schatten: Passt sich an Theme an
- **Gesamt-Zeile**: Gelber Hintergrund mit dunklem/hellem Text für perfekten Kontrast

---

## Checkliste für zukünftige UI-Elemente

Bei neuen UI-Komponenten beachten:

- [ ] Keine festen `Colors.grey[X]` verwenden
- [ ] Stattdessen `Theme.of(context).colorScheme.*` nutzen
- [ ] Bei farbigen Hintergründen: Textfarbe explizit setzen
- [ ] Dark Mode Varianten testen (dunklere Farben mit Opacity)
- [ ] `WidgetStateProperty` statt `MaterialStateProperty`
- [ ] Kontrast-Ratio: mindestens 4.5:1 für normalen Text

---

**Datum**: 17. Oktober 2025
**Geänderte Screens**: 3 (Wizard, Kniffel, Skyjo)
**Status**: ✅ Alle Kontraste optimiert
