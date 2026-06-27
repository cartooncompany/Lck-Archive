import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/paged_response.dart';
import 'package:frontend/features/teams/data/dto/team_match_dto.dart';
import 'package:frontend/features/matches/data/dto/match_detail_dto.dart';

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

  Future<MatchDetailDto> getMatchDetail(String id) {
    return _apiClient.get(
      '/matches/$id',
      decoder: (data) => MatchDetailDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<TeamMatchDto>> getRecentResults({int limit = 5}) {
    return _apiClient.get(
      '/matches/recent-results',
      queryParameters: {
        'limit': limit,
      },
      decoder: (data) => (data as List<dynamic>)
          .map((item) => TeamMatchDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> requestLckSync() {
    return _apiClient.postVoid('/crawler/lck/sync');
  }
}
