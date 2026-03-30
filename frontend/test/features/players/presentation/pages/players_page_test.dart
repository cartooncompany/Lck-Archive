import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_dependencies.dart';
import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/players/presentation/pages/players_page.dart';

void main() {
  group('PlayersPage search', () {
    Future<void> pumpPlayersPage(WidgetTester tester) async {
      final controller = FavoriteTeamController(
        initialTeam: MockLckData.defaultFavoriteTeam,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        AppDependenciesScope(
          dependencies: AppDependencies.create(),
          child: FavoriteTeamScope(
            controller: controller,
            child: const MaterialApp(home: Scaffold(body: PlayersPage())),
          ),
        ),
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
