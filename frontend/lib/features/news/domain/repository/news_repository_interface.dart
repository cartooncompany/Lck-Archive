import '../../../../core/network/paged_response.dart';
import '../../../../shared/models/news_article.dart';

abstract class INewsRepository {
  Future<PagedResponse<NewsArticle>> getNews({
    int page = 1,
    int limit = 20,
    String? source,
    String? keyword,
    String sortOrder = 'desc',
  });
  Future<List<NewsArticle>> getFeaturedNewsForTeam({
    required String teamName,
    String? shortName,
    int limit = 3,
  });
}
