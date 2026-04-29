import 'dart:math' as math;

import '../../../../core/network/paged_response.dart';
import '../../../../core/network/pagination_meta.dart';
import '../../../../shared/models/news_article.dart';
import '../datasource/news_remote_data_source.dart';
import '../dto/news_item_dto.dart';

class NewsRepository {
  static const int _remotePageLimit = 100;

  NewsRepository({required NewsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final NewsRemoteDataSource _remoteDataSource;

  Future<PagedResponse<NewsArticle>> getNews({
    int page = 1,
    int limit = 20,
    String? source,
    String? keyword,
    String sortOrder = 'desc',
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = math.min(math.max(limit, 1), 100);
    final normalizedKeyword = keyword?.trim();
    final normalizedSource = source?.trim().toUpperCase();

    if (normalizedSource == 'LOLESPORTS') {
      final response = await _remoteDataSource.getNews(
        page: safePage,
        limit: safeLimit,
        source: source,
        keyword: normalizedKeyword,
        sortOrder: sortOrder,
      );
      return PagedResponse(
        items: response.items.map(_mapNewsItem).toList(),
        meta: response.meta,
      );
    }

    final articles = await _getFilteredRemoteNews(
      source: source,
      keyword: normalizedKeyword,
      sortOrder: sortOrder,
    );
    return _paginateArticles(articles, page: safePage, limit: safeLimit);
  }

  Future<List<NewsArticle>> getFeaturedNewsForTeam({
    required String teamName,
    String? shortName,
    int limit = 3,
  }) async {
    final safeLimit = math.max(limit, 1);
    final normalizedTeamName = teamName.trim();
    final normalizedShortName = shortName?.trim();
    final keywords = <String>[
      if (normalizedShortName != null && normalizedShortName.isNotEmpty)
        normalizedShortName,
      if (normalizedTeamName.isNotEmpty &&
          normalizedTeamName.toLowerCase() !=
              normalizedShortName?.toLowerCase())
        normalizedTeamName,
    ];

    final articlesById = <String, NewsArticle>{};
    for (final keyword in keywords) {
      final response = await getNews(keyword: keyword, limit: safeLimit);
      for (final article in response.items) {
        articlesById.putIfAbsent(article.id, () => article);
      }
      if (articlesById.length >= safeLimit) {
        break;
      }
    }

    if (articlesById.isEmpty) {
      final response = await getNews(limit: safeLimit);
      return response.items.take(safeLimit).toList();
    }

    final articles = articlesById.values.toList()
      ..sort((left, right) => _compareByPublishedAt(right, left));
    return articles.take(safeLimit).toList();
  }

  NewsArticle _mapNewsItem(NewsItemDto dto) {
    return NewsArticle(
      id: dto.id,
      title: dto.title,
      summary: dto.summary,
      thumbnailUrl: dto.thumbnailUrl,
      articleUrl: dto.articleUrl,
      publisher: dto.publisher,
      source: dto.source,
      publishedAt: dto.publishedAt,
      publishedAtText: dto.publishedAtText,
    );
  }

  Future<List<NewsArticle>> _getFilteredRemoteNews({
    String? source,
    String? keyword,
    required String sortOrder,
  }) async {
    final collectedArticles = <NewsArticle>[];
    var currentPage = 1;
    var totalPages = 1;

    while (currentPage <= totalPages) {
      final response = await _remoteDataSource.getNews(
        page: currentPage,
        limit: _remotePageLimit,
        source: source,
        keyword: keyword,
        sortOrder: sortOrder,
      );
      totalPages = response.meta.totalPages;
      collectedArticles.addAll(
        response.items
            .map(_mapNewsItem)
            .where((article) => article.isVisibleNews),
      );
      currentPage += 1;
    }

    return collectedArticles;
  }

  PagedResponse<NewsArticle> _paginateArticles(
    List<NewsArticle> articles, {
    required int page,
    required int limit,
  }) {
    final start = (page - 1) * limit;
    final end = math.min(start + limit, articles.length);
    final items = start >= articles.length
        ? const <NewsArticle>[]
        : articles.sublist(start, end);
    final totalPages = articles.isEmpty ? 0 : (articles.length / limit).ceil();

    return PagedResponse(
      items: items,
      meta: PaginationMeta(
        page: page,
        limit: limit,
        total: articles.length,
        totalPages: totalPages,
      ),
    );
  }

  int _compareByPublishedAt(NewsArticle left, NewsArticle right) {
    final leftTime = left.publishedAt?.millisecondsSinceEpoch ?? 0;
    final rightTime = right.publishedAt?.millisecondsSinceEpoch ?? 0;
    if (leftTime != rightTime) {
      return leftTime.compareTo(rightTime);
    }
    return left.title.compareTo(right.title);
  }
}
