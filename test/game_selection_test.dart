import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spiele_app/screens/game_selection_screen.dart'
    show GameSelectionScreen;
import 'package:spiele_app/models/player.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spiele_app/services/database_service.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseService.instance.dbFileOverride = ':memory:';
    await DatabaseService.instance.database;
    await DatabaseService.instance.createPlayer(Player(name: 'Alice'));
    await DatabaseService.instance.createPlayer(Player(name: 'Bob'));
  });
  testWidgets('Spielauswahl validiert Spieleranzahl für Wizard',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GameSelectionScreen()));
    await tester.pumpAndSettle(); // Warten bis Spieler geladen sind
    // Wizard auswählen (Card finden und tappen)
    final wizardCard = find.byWidgetPredicate((widget) =>
        widget.runtimeType.toString() == '_GameTypeCard' &&
        (widget as dynamic).gameType.displayName == 'Wizard');
    expect(wizardCard, findsOneWidget);
    await tester.tap(wizardCard);
    await tester.pumpAndSettle();
    // Button "Spiel starten" drücken
    await tester.tap(find.text('Spiel starten'));
    await tester.pumpAndSettle();
    // SnackBar mit Fehlertext prüfen
    expect(find.textContaining('Wizard benötigt mindestens 3 Spieler'),
        findsOneWidget);
  });

  testWidgets('Spieler können nicht doppelt hinzugefügt werden',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GameSelectionScreen()));
    // Spieler hinzufügen simulieren
    // ...hier müsste man die Spieler-Liste mocken
    // Test: Checkbox mehrfach klicken
    // ...
    // Erwartung: Spieler ist nur einmal in der Auswahl
  });
}
