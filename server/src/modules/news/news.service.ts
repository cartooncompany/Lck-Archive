import { Injectable } from '@nestjs/common';
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
  constructor(private readonly newsRepository: NewsRepository) {}

  async getNews(query: GetNewsQueryDto): Promise<NewsListResponseDto> {
    const [articles, total] = await Promise.all([
      this.newsRepository.findMany(query),
      this.newsRepository.count(query),
    ]);

    return {
      items: articles.map((article) => this.toSummary(article)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };
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
