import '../core/network/api_base_url.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/shared_preferences_local_storage.dart';
import '../core/logging/app_logger.dart';
import '../features/auth/data/datasource/auth_remote_data_source.dart';
import '../features/auth/data/repository/auth_repository.dart';
import '../features/auth/domain/repository/auth_repository_interface.dart';
import '../features/matches/data/datasource/matches_remote_data_source.dart';
import '../features/matches/data/repository/matches_repository.dart';
import '../features/matches/domain/repository/matches_repository_interface.dart';
import '../features/news/data/datasource/news_remote_data_source.dart';
import '../features/news/data/repository/news_repository.dart';
import '../features/news/domain/repository/news_repository_interface.dart';
import '../features/players/data/datasource/players_remote_data_source.dart';
import '../features/players/data/repository/players_repository.dart';
import '../features/players/domain/repository/players_repository_interface.dart';
import '../features/teams/data/datasource/teams_remote_data_source.dart';
import '../features/teams/data/repository/teams_repository.dart';
import '../features/teams/domain/repository/teams_repository_interface.dart';

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
    final authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSource(apiClient),
      localStorage: localStorage,
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
