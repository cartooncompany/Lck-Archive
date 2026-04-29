import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/app_dependencies.dart';
import 'package:frontend/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repository/auth_repository.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/matches/data/datasource/matches_remote_data_source.dart';
import 'package:frontend/features/matches/data/repository/matches_repository.dart';
import 'package:frontend/features/news/data/datasource/news_remote_data_source.dart';
import 'package:frontend/features/news/data/repository/news_repository.dart';
import 'package:frontend/features/players/data/datasource/players_remote_data_source.dart';
import 'package:frontend/features/players/data/repository/players_repository.dart';
import 'package:frontend/features/players/presentation/pages/players_page.dart';
import 'package:frontend/features/teams/data/datasource/teams_remote_data_source.dart';
import 'package:frontend/features/teams/data/repository/teams_repository.dart';
import '../../../../test_helpers/sample_lck_test_data.dart';

void main() {
  group('PlayersPage search', () {
    Future<void> pumpPlayersPage(WidgetTester tester) async {
      final apiClient = SampleLckApiClient();
      final localStorage = MemoryLocalStorage();
      final teamsRepository = TeamsRepository(
        remoteDataSource: TeamsRemoteDataSource(apiClient),
        localStorage: localStorage,
      );
      final dependencies = AppDependencies(
        apiClient: apiClient,
        localStorage: localStorage,
        authRepository: AuthRepository(
          remoteDataSource: AuthRemoteDataSource(apiClient),
          localStorage: localStorage,
        ),
        teamsRepository: teamsRepository,
        playersRepository: PlayersRepository(
          remoteDataSource: PlayersRemoteDataSource(apiClient),
          teamsRepository: teamsRepository,
          localStorage: localStorage,
        ),
        matchesRepository: MatchesRepository(
          remoteDataSource: MatchesRemoteDataSource(apiClient),
        ),
        newsRepository: NewsRepository(
          remoteDataSource: NewsRemoteDataSource(apiClient),
        ),
      );
      final controller = FavoriteTeamController(
        initialTeam: sampleFavoriteTeam,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        AppDependenciesScope(
          dependencies: dependencies,
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
