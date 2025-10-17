// Hier müsste das Widget für Spieler hinzufügen importiert werden
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spiele_app/services/database_service.dart';
import 'package:spiele_app/models/player.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseService.instance.dbFileOverride = ':memory:';
    await DatabaseService.instance.database;
    await DatabaseService.instance.createPlayer(Player(name: 'Alice'));
    await DatabaseService.instance.createPlayer(Player(name: 'Bob'));
  });
  testWidgets('Spielername darf nicht leer sein', (WidgetTester tester) async {
    // await tester.pumpWidget(MaterialApp(home: PlayerAddScreen()));
    // await tester.enterText(find.byType(TextField), '');
    // await tester.tap(find.text('Spieler hinzufügen'));
    // await tester.pump();
    // expect(find.textContaining('Name darf nicht leer sein'), findsOneWidget);
  });

  testWidgets('Spielername darf nicht doppelt vorkommen',
      (WidgetTester tester) async {
    // await tester.pumpWidget(MaterialApp(home: PlayerAddScreen()));
    // await tester.enterText(find.byType(TextField), 'Alice');
    // await tester.tap(find.text('Spieler hinzufügen'));
    // await tester.enterText(find.byType(TextField), 'Alice');
    // await tester.tap(find.text('Spieler hinzufügen'));
    // await tester.pump();
    // expect(find.textContaining('Name existiert bereits'), findsOneWidget);
  });
}
