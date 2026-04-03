import '../../../../core/network/api_client.dart';
import '../../../../core/network/paged_response.dart';
import '../../../teams/data/dto/team_match_dto.dart';

class MatchesRemoteDataSource {
  const MatchesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResponse<TeamMatchDto>> getScheduledMatches({
    required DateTime from,
    DateTime? to,
  }) {
    return _apiClient.get(
      '/matches',
      queryParameters: {
        'status': 'SCHEDULED',
        'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
        'sortOrder': 'asc',
      },
      decoder: (data) => PagedResponse<TeamMatchDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: TeamMatchDto.fromJson,
      ),
    );
  }

  Future<void> requestLckSync() {
    return _apiClient.postVoid('/crawler/lck/sync');
  }
}
