import { Injectable } from '@nestjs/common';
import { CacheInvalidatorService } from '../../common/cache/cache-invalidator.service';
import { CacheNamespace } from '../../common/cache/cache-namespaces';
import { buildCacheKey } from '../../common/utils/cache-key.util';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetNewsQueryDto } from './dto/get-news.query.dto';
import { NewsArticleEntity } from './entities/news-article.entity';
import { NewsRepository } from './news.repository';
import {
  NewsListResponseDto,
  NewsSummaryResponseDto,
} from './responses/news-summary.response';

@Injectable()
export class NewsService {
  constructor(
    private readonly newsRepository: NewsRepository,
    private readonly cache: CacheInvalidatorService,
  ) {}

  async getNews(query: GetNewsQueryDto): Promise<NewsListResponseDto> {
    const cacheKey = buildCacheKey(CacheNamespace.NEWS, 'list', query);
    const cached = await this.cache.get<NewsListResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const [articles, total] = await Promise.all([
      this.newsRepository.findMany(query),
      this.newsRepository.count(query),
    ]);

    const result = {
      items: articles.map((article) => this.toSummary(article)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cache.set(CacheNamespace.NEWS, cacheKey, result, 5 * 60 * 1000); // 5분 캐싱
    return result;
  }

  private toSummary(article: NewsArticleEntity): NewsSummaryResponseDto {
    return {
      id: article.id,
      title: article.title,
      summary: article.summary,
      thumbnailUrl: article.thumbnailUrl,
      articleUrl: article.articleUrl,
      publisher: article.publisher,
      source: article.externalSource,
      publishedAt: article.publishedAt,
      publishedAtText: article.publishedAtText,
    };
  }
}
