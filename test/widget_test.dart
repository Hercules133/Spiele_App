// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:spiele_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpieleApp());
    await tester.pumpAndSettle();

    // Verify that the home screen is displayed.
    expect(find.text('Spiele Punkteverwaltung'), findsOneWidget);
    expect(find.text('Neues Spiel starten'), findsOneWidget);
    expect(find.text('Spiel-History'), findsOneWidget);
    expect(find.text('Spieler verwalten'), findsOneWidget);
    expect(find.text('Bestenlisten'), findsOneWidget);
  });
}
