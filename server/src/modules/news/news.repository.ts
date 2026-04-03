import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { GetNewsQueryDto } from './dto/get-news.query.dto';
import { NewsArticleEntity } from './entities/news-article.entity';

const newsArticleSelect = Prisma.validator<Prisma.NewsArticleSelect>()({
  id: true,
  title: true,
  summary: true,
  thumbnailUrl: true,
  articleUrl: true,
  publisher: true,
  externalSource: true,
  externalId: true,
  publishedAt: true,
  publishedAtText: true,
  createdAt: true,
  updatedAt: true,
});

@Injectable()
export class NewsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(query: GetNewsQueryDto): Promise<NewsArticleEntity[]> {
    const articles = await this.prisma.newsArticle.findMany({
      where: this.buildWhere(query),
      select: newsArticleSelect,
      orderBy: [
        { publishedAt: query.sortOrder },
        { createdAt: query.sortOrder },
      ],
      skip: query.skip,
      take: query.limit,
    });

    return articles as NewsArticleEntity[];
  }

  async count(query: GetNewsQueryDto): Promise<number> {
    return this.prisma.newsArticle.count({
      where: this.buildWhere(query),
    });
  }

  private buildWhere(query: GetNewsQueryDto): Prisma.NewsArticleWhereInput {
    const conditions: Prisma.NewsArticleWhereInput[] = [];

    if (query.source) {
      conditions.push({ externalSource: query.source });
    }

    if (query.keyword) {
      conditions.push({
        OR: [
          {
            title: {
              contains: query.keyword,
              mode: 'insensitive',
            },
          },
          {
            summary: {
              contains: query.keyword,
              mode: 'insensitive',
            },
          },
          {
            publisher: {
              contains: query.keyword,
              mode: 'insensitive',
            },
          },
        ],
      });
    }

    return conditions.length > 0 ? { AND: conditions } : {};
  }
}
