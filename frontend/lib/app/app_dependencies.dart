import '../core/network/api_base_url.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../features/matches/data/datasource/matches_remote_data_source.dart';
import '../features/matches/data/repository/matches_repository.dart';
import '../features/players/data/datasource/players_remote_data_source.dart';
import '../features/players/data/repository/players_repository.dart';
import '../features/teams/data/datasource/teams_remote_data_source.dart';
import '../features/teams/data/repository/teams_repository.dart';

class AppDependencies {
  AppDependencies({
    required this.apiClient,
    required this.teamsRepository,
    required this.playersRepository,
    required this.matchesRepository,
  });

  factory AppDependencies.create() {
    final apiClient = DioApiClient(baseUrl: resolveApiBaseUrl());
    final teamsRepository = TeamsRepository(
      remoteDataSource: TeamsRemoteDataSource(apiClient),
    );
    final playersRepository = PlayersRepository(
      remoteDataSource: PlayersRemoteDataSource(apiClient),
      teamsRepository: teamsRepository,
    );
    final matchesRepository = MatchesRepository(
      remoteDataSource: MatchesRemoteDataSource(apiClient),
    );

    return AppDependencies(
      apiClient: apiClient,
      teamsRepository: teamsRepository,
      playersRepository: playersRepository,
      matchesRepository: matchesRepository,
    );
  }

  final ApiClient apiClient;
  final TeamsRepository teamsRepository;
  final PlayersRepository playersRepository;
  final MatchesRepository matchesRepository;
}
