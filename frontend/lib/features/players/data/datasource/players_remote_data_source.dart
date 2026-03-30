import '../../../../core/network/api_client.dart';
import '../../../../core/network/paged_response.dart';
import '../dto/player_detail_dto.dart';
import '../dto/player_summary_dto.dart';

class PlayersRemoteDataSource {
  const PlayersRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResponse<PlayerSummaryDto>> getPlayers({
    String? teamId,
    String? position,
    String? keyword,
    int page = 1,
    int limit = 100,
  }) {
    return _apiClient.get(
      '/players',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (teamId != null && teamId.isNotEmpty) 'teamId': teamId,
        if (position != null && position.isNotEmpty) 'position': position,
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
      },
      decoder: (data) => PagedResponse<PlayerSummaryDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: PlayerSummaryDto.fromJson,
      ),
    );
  }

  Future<PlayerDetailDto> getPlayerDetail(String id) {
    return _apiClient.get(
      '/players/$id',
      decoder: (data) => PlayerDetailDto.fromJson(data as Map<String, dynamic>),
    );
  }
}
