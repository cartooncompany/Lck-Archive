import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_dependencies.dart';
import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/matches/data/datasource/matches_remote_data_source.dart';
import 'package:frontend/features/matches/data/repository/matches_repository.dart';
import 'package:frontend/features/my_page/presentation/pages/my_page_page.dart';
import 'package:frontend/features/news/data/datasource/news_remote_data_source.dart';
import 'package:frontend/features/news/data/repository/news_repository.dart';
import 'package:frontend/features/players/data/datasource/players_remote_data_source.dart';
import 'package:frontend/features/players/data/repository/players_repository.dart';
import 'package:frontend/features/settings/presentation/pages/settings_page.dart';
import 'package:frontend/features/teams/data/datasource/teams_remote_data_source.dart';
import 'package:frontend/features/teams/data/repository/teams_repository.dart';

void main() {
  testWidgets('favorite team picker does not overflow on a short screen', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 640));

    final controller = FavoriteTeamController(
      initialTeam: MockLckData.defaultFavoriteTeam,
    );
    final apiClient = _ThrowingApiClient();
    final localStorage = _MemoryLocalStorage();
    final teamsRepository = TeamsRepository(
      remoteDataSource: TeamsRemoteDataSource(apiClient),
      localStorage: localStorage,
    );
    final dependencies = AppDependencies(
      apiClient: apiClient,
      localStorage: localStorage,
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
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AppDependenciesScope(
        dependencies: dependencies,
        child: FavoriteTeamScope(
          controller: controller,
          child: MaterialApp(
            theme: AppTheme.dark(),
            routes: {AppRouter.settings: (_) => const SettingsPage()},
            home: const MyPagePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('응원팀 변경'));
    await tester.pumpAndSettle();

    expect(find.text('응원팀 선택'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ThrowingApiClient implements ApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  }) {
    throw Exception('Network disabled in widget tests.');
  }

  @override
  Future<void> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw Exception('Network disabled in widget tests.');
  }
}

class _MemoryLocalStorage implements LocalStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> readString(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}
