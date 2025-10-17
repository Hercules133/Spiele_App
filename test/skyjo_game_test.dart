import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spiele_app/screens/skyjo_game_screen.dart';
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
  testWidgets('Skyjo: Punkte müssen eingegeben werden',
      (WidgetTester tester) async {
    final players = [Player(id: 1, name: 'Alice'), Player(id: 2, name: 'Bob')];
    await tester.pumpWidget(
        MaterialApp(home: SkyjoGameScreen(gameId: 1, players: players)));
    // Keine Eingabe
    await tester.tap(find.text('Runde speichern'));
    await tester.pump();
    expect(find.textContaining('Bitte gib für alle Spieler Punkte ein'),
        findsOneWidget);
  });

  testWidgets('Skyjo: Negative Punkte werden akzeptiert (Regelkonform)',
      (WidgetTester tester) async {
    final players = [Player(id: 1, name: 'Alice'), Player(id: 2, name: 'Bob')];
    await tester.pumpWidget(
        MaterialApp(home: SkyjoGameScreen(gameId: 1, players: players)));
    await tester.enterText(find.byType(TextField).at(0), '-5');
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.tap(find.text('Runde speichern'));
    await tester.pump();
    // Erwartung: Runde wird gespeichert
    expect(find.textContaining('Runde gespeichert!'), findsOneWidget);
  });

  testWidgets('Skyjo: Spiel endet automatisch bei >100 Punkten',
      (WidgetTester tester) async {
    final players = [Player(id: 1, name: 'Alice'), Player(id: 2, name: 'Bob')];
    await tester.pumpWidget(
        MaterialApp(home: SkyjoGameScreen(gameId: 1, players: players)));
    // Simuliere viele Runden für Alice
    for (int i = 0; i < 11; i++) {
      await tester.enterText(find.byType(TextField).at(0), '10');
      await tester.enterText(find.byType(TextField).at(1), '5');
      await tester.tap(find.text('Runde speichern'));
      await tester.pump();
    }
    // Erwartung: Spiel beendet Dialog erscheint
    expect(find.textContaining('Spiel beendet!'), findsOneWidget);
  });
}
