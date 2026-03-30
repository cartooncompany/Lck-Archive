import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/players/presentation/pages/players_page.dart';

void main() {
  group('PlayersPage search', () {
    Future<void> pumpPlayersPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayersPage())),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('keeps short name queries from matching team name substrings', (
      tester,
    ) async {
      await pumpPlayersPage(tester);

      await tester.enterText(find.byType(TextField), 'f');
      await tester.pumpAndSettle();

      expect(find.text('Faker'), findsOneWidget);
      expect(find.text('Deft'), findsOneWidget);
      expect(find.text('Zeka'), findsNothing);
      expect(find.text('Viper'), findsNothing);
      expect(find.text('Delight'), findsNothing);
    });

    testWidgets('still supports team-name searches through word prefixes', (
      tester,
    ) async {
      await pumpPlayersPage(tester);

      await tester.enterText(find.byType(TextField), 'hle');
      await tester.pumpAndSettle();

      expect(find.text('Zeka'), findsOneWidget);
      expect(find.text('Viper'), findsOneWidget);
      expect(find.text('Delight'), findsOneWidget);
      expect(find.text('Faker'), findsNothing);
    });
  });
}
