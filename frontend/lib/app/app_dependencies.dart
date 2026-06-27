import 'package:frontend/core/network/api_base_url.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/auth_interceptor.dart';
import 'package:frontend/core/network/dio_api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/storage/shared_preferences_local_storage.dart';
import 'package:frontend/core/storage/secure_local_storage.dart';
import 'package:frontend/core/logging/app_logger.dart';
import 'package:frontend/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/datasource/auth_session_store.dart';
import 'package:frontend/features/auth/data/repository/auth_repository.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:frontend/features/matches/data/datasource/matches_remote_data_source.dart';
import 'package:frontend/features/matches/data/repository/matches_repository.dart';
import 'package:frontend/features/matches/domain/repository/matches_repository_interface.dart';
import 'package:frontend/features/news/data/datasource/news_remote_data_source.dart';
import 'package:frontend/features/news/data/repository/news_repository.dart';
import 'package:frontend/features/news/domain/repository/news_repository_interface.dart';
import 'package:frontend/features/players/data/datasource/players_remote_data_source.dart';
import 'package:frontend/features/players/data/repository/players_repository.dart';
import 'package:frontend/features/players/domain/repository/players_repository_interface.dart';
import 'package:frontend/features/teams/data/datasource/teams_remote_data_source.dart';
import 'package:frontend/features/teams/data/repository/teams_repository.dart';
import 'package:frontend/features/teams/domain/repository/teams_repository_interface.dart';

class AppDependencies {
  AppDependencies({
    required this.apiClient,
    required this.localStorage,
    required this.authRepository,
    required this.teamsRepository,
    required this.playersRepository,
    required this.matchesRepository,
    required this.newsRepository,
  });

  static Future<AppDependencies> create() async {
    final baseUrl = resolveApiBaseUrl();
    AppLogger.info(
      'Creating application dependencies.',
      tag: 'BOOT',
      data: {'apiBaseUrl': baseUrl},
    );
    final apiClient = DioApiClient(baseUrl: baseUrl);
    final localStorage = await SharedPreferencesLocalStorage.create();
    final secureStorage = SecureLocalStorage.create();

    final authRemoteDataSource = AuthRemoteDataSource(apiClient);
    final authSessionStore = AuthSessionStore(
      remoteDataSource: authRemoteDataSource,
      localStorage: secureStorage,
    );
    // 모든 요청에 토큰 자동 주입 + 401 시 자동 갱신/재시도.
    apiClient.addAuthInterceptor(
      AuthInterceptor(sessionStore: authSessionStore, dio: apiClient.dio),
    );
    final authRepository = AuthRepository(
      remoteDataSource: authRemoteDataSource,
      sessionStore: authSessionStore,
    );
    final teamsRepository = TeamsRepository(
      remoteDataSource: TeamsRemoteDataSource(apiClient),
      localStorage: localStorage,
    );
    final playersRepository = PlayersRepository(
      remoteDataSource: PlayersRemoteDataSource(apiClient),
      teamsRepository: teamsRepository,
      localStorage: localStorage,
    );
    final matchesRepository = MatchesRepository(
      remoteDataSource: MatchesRemoteDataSource(apiClient),
    );
    final newsRepository = NewsRepository(
      remoteDataSource: NewsRemoteDataSource(apiClient),
    );

    return AppDependencies(
      apiClient: apiClient,
      localStorage: localStorage,
      authRepository: authRepository,
      teamsRepository: teamsRepository,
      playersRepository: playersRepository,
      matchesRepository: matchesRepository,
      newsRepository: newsRepository,
    );
  }

  final ApiClient apiClient;
  final LocalStorage localStorage;
  final IAuthRepository authRepository;
  final ITeamsRepository teamsRepository;
  final IPlayersRepository playersRepository;
  final IMatchesRepository matchesRepository;
  final INewsRepository newsRepository;
}
