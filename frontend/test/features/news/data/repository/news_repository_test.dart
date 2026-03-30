import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/pagination_meta.dart';
import 'package:frontend/core/network/paged_response.dart';
import 'package:frontend/features/news/data/datasource/news_remote_data_source.dart';
import 'package:frontend/features/news/data/dto/news_item_dto.dart';
import 'package:frontend/features/news/data/repository/news_repository.dart';

void main() {
  late NewsRepository repository;

  setUp(() {
    repository = NewsRepository(
      remoteDataSource: _ThrowingNewsRemoteDataSource(),
    );
  });

  test(
    'falls back to local news data with source and keyword filters',
    () async {
      final response = await repository.getNews(
        source: 'NAVER_ESPORTS',
        keyword: 'Hanwha',
        limit: 10,
      );

      expect(response.items, hasLength(1));
      expect(response.items.first.source, 'NAVER_ESPORTS');
      expect(response.items.first.title, contains('Hanwha'));
      expect(response.meta.total, 1);
      expect(response.meta.totalPages, 1);
    },
  );

  test('supports fallback pagination with ascending sort order', () async {
    final response = await repository.getNews(limit: 2, sortOrder: 'asc');

    expect(response.items.map((article) => article.id), ['news-5', 'news-4']);
    expect(response.meta.page, 1);
    expect(response.meta.limit, 2);
    expect(response.meta.total, 5);
    expect(response.meta.totalPages, 3);
  });

  test(
    'filters out non-LCK naver esports articles from remote responses',
    () async {
      final remoteRepository = NewsRepository(
        remoteDataSource: _StubNewsRemoteDataSource(
          responses: {
            1: PagedResponse(
              items: const [
                NewsItemDto(
                  id: 'naver-lck-1',
                  title: 'LCK T1 경기 분석',
                  summary: 'LCK 상위권 경쟁이 치열해졌습니다.',
                  thumbnailUrl: null,
                  articleUrl: 'https://example.com/1',
                  publisher: 'Naver',
                  source: 'NAVER_ESPORTS',
                  publishedAt: null,
                  publishedAtText: null,
                ),
                NewsItemDto(
                  id: 'naver-other',
                  title: '발로란트 국제전 소식',
                  summary: '다른 종목 기사입니다.',
                  thumbnailUrl: null,
                  articleUrl: 'https://example.com/2',
                  publisher: 'Naver',
                  source: 'NAVER_ESPORTS',
                  publishedAt: null,
                  publishedAtText: null,
                ),
              ],
              meta: PaginationMeta(
                page: 1,
                limit: 100,
                total: 4,
                totalPages: 2,
              ),
            ),
            2: PagedResponse(
              items: const [
                NewsItemDto(
                  id: 'lolesports',
                  title: 'MSI 파워랭킹',
                  summary: 'LoL Esports 기사입니다.',
                  thumbnailUrl: null,
                  articleUrl: 'https://example.com/3',
                  publisher: 'Riot',
                  source: 'LOLESPORTS',
                  publishedAt: null,
                  publishedAtText: null,
                ),
                NewsItemDto(
                  id: 'naver-lck-2',
                  title: '플레이오프 변수 점검',
                  summary: 'LCK 결승 경쟁 팀들의 변수 정리.',
                  thumbnailUrl: null,
                  articleUrl: 'https://example.com/4',
                  publisher: 'Naver',
                  source: 'NAVER_ESPORTS',
                  publishedAt: null,
                  publishedAtText: null,
                ),
              ],
              meta: PaginationMeta(
                page: 2,
                limit: 100,
                total: 4,
                totalPages: 2,
              ),
            ),
          },
        ),
      );

      final response = await remoteRepository.getNews(page: 2, limit: 1);

      expect(response.items, hasLength(1));
      expect(response.items.first.id, 'lolesports');
      expect(response.meta.total, 3);
      expect(response.meta.totalPages, 3);
    },
  );
}

class _ThrowingNewsRemoteDataSource extends NewsRemoteDataSource {
  _ThrowingNewsRemoteDataSource() : super(_FakeApiClient());

  @override
  Future<PagedResponse<NewsItemDto>> getNews({
    int page = 1,
    int limit = 20,
    String? source,
    String? keyword,
    String sortOrder = 'desc',
  }) async {
    throw Exception('network unavailable');
  }
}

class _FakeApiClient implements ApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }
}

class _StubNewsRemoteDataSource extends NewsRemoteDataSource {
  _StubNewsRemoteDataSource({required this.responses})
    : super(_FakeApiClient());

  final Map<int, PagedResponse<NewsItemDto>> responses;

  @override
  Future<PagedResponse<NewsItemDto>> getNews({
    int page = 1,
    int limit = 20,
    String? source,
    String? keyword,
    String sortOrder = 'desc',
  }) async {
    final response = responses[page];
    if (response == null) {
      throw Exception('missing stub response for page $page');
    }
    return response;
  }
}
