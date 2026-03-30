import '../core/network/api_base_url.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../features/players/data/datasource/players_remote_data_source.dart';
import '../features/players/data/repository/players_repository.dart';
import '../features/teams/data/datasource/teams_remote_data_source.dart';
import '../features/teams/data/repository/teams_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.apiClient,
    required this.teamsRepository,
    required this.playersRepository,
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

    return AppDependencies._(
      apiClient: apiClient,
      teamsRepository: teamsRepository,
      playersRepository: playersRepository,
    );
  }

  final ApiClient apiClient;
  final TeamsRepository teamsRepository;
  final PlayersRepository playersRepository;
}
