import '../../../../core/network/api_client.dart';
import '../../../../core/network/paged_response.dart';
import '../dto/team_detail_dto.dart';
import '../dto/team_match_dto.dart';
import '../dto/team_summary_dto.dart';

class TeamsRemoteDataSource {
  const TeamsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResponse<TeamSummaryDto>> getTeams({
    String? keyword,
    int page = 1,
    int limit = 100,
  }) {
    return _apiClient.get(
      '/teams',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
      },
      decoder: (data) => PagedResponse<TeamSummaryDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: TeamSummaryDto.fromJson,
      ),
    );
  }

  Future<TeamDetailDto> getTeamDetail(String id) {
    return _apiClient.get(
      '/teams/$id',
      decoder: (data) => TeamDetailDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<PagedResponse<TeamMatchDto>> getTeamMatches(
    String id, {
    int page = 1,
    int limit = 5,
    int? seasonYear,
    String? split,
    String? stage,
    String? status,
  }) {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    if (seasonYear != null) {
      queryParameters['seasonYear'] = seasonYear;
    }
    if (split != null && split.trim().isNotEmpty) {
      queryParameters['split'] = split;
    }
    if (stage != null && stage.trim().isNotEmpty) {
      queryParameters['stage'] = stage;
    }
    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status;
    }

    return _apiClient.get(
      '/teams/$id/matches',
      queryParameters: queryParameters,
      decoder: (data) => PagedResponse<TeamMatchDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: TeamMatchDto.fromJson,
      ),
    );
  }
}
