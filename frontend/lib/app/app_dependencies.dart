import '../core/network/api_base_url.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/shared_preferences_local_storage.dart';
import '../features/auth/data/datasource/auth_remote_data_source.dart';
import '../features/auth/data/repository/auth_repository.dart';
import '../features/matches/data/datasource/matches_remote_data_source.dart';
import '../features/matches/data/repository/matches_repository.dart';
import '../features/news/data/datasource/news_remote_data_source.dart';
import '../features/news/data/repository/news_repository.dart';
import '../features/players/data/datasource/players_remote_data_source.dart';
import '../features/players/data/repository/players_repository.dart';
import '../features/teams/data/datasource/teams_remote_data_source.dart';
import '../features/teams/data/repository/teams_repository.dart';

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
    final apiClient = DioApiClient(baseUrl: resolveApiBaseUrl());
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
  final AuthRepository authRepository;
  final TeamsRepository teamsRepository;
  final PlayersRepository playersRepository;
  final MatchesRepository matchesRepository;
  final NewsRepository newsRepository;
}
