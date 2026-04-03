import '../../../../core/network/api_client.dart';
import '../../../../core/network/paged_response.dart';
import '../dto/news_item_dto.dart';

class NewsRemoteDataSource {
  const NewsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResponse<NewsItemDto>> getNews({
    int page = 1,
    int limit = 20,
    String? source,
    String? keyword,
    String sortOrder = 'desc',
  }) {
    return _apiClient.get(
      '/news',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortOrder': sortOrder,
        if (source != null && source.trim().isNotEmpty) 'source': source,
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
      },
      decoder: (data) => PagedResponse<NewsItemDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: NewsItemDto.fromJson,
      ),
    );
  }
}
