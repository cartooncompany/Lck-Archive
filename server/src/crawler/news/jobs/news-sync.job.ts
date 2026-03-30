import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../database/prisma.service';
import { NewsScraperClient } from '../client/news-scraper.client';
import { ScrapedNewsArticle } from '../types/news-source.types';

@Injectable()
export class NewsSyncJob {
  private readonly logger = new Logger(NewsSyncJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly newsScraperClient: NewsScraperClient,
  ) {}

  async sync(): Promise<{ newsArticles: number }> {
    const log = await this.prisma.syncJobLog.create({
      data: {
        jobName: 'news-sync',
        status: 'RUNNING',
      },
    });

    try {
      const articles = await this.newsScraperClient.fetchLatestNews();

      await this.prisma.$transaction(async (tx) => {
        for (const article of articles) {
          await tx.newsArticle.upsert(this.toUpsertArgs(article));
        }
      });

      await this.prisma.syncJobLog.update({
        where: { id: log.id },
        data: {
          status: 'SUCCESS',
          finishedAt: new Date(),
          recordsCount: articles.length,
        },
      });

      return {
        newsArticles: articles.length,
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown sync error';

      this.logger.error(`News sync failed: ${message}`);

      await this.prisma.syncJobLog.update({
        where: { id: log.id },
        data: {
          status: 'FAILED',
          message,
          finishedAt: new Date(),
        },
      });

      throw error;
    }
  }

  private toUpsertArgs(
    article: ScrapedNewsArticle,
  ): Prisma.NewsArticleUpsertArgs {
    const data: Prisma.NewsArticleUncheckedCreateInput = {
      title: article.title,
      summary: article.summary,
      thumbnailUrl: article.thumbnailUrl,
      articleUrl: article.articleUrl,
      publisher: article.publisher,
      externalSource: article.externalSource,
      externalId: article.externalId,
      publishedAt: article.publishedAt,
      publishedAtText: article.publishedAtText,
    };

    return {
      where: {
        externalSource_externalId: {
          externalSource: article.externalSource,
          externalId: article.externalId,
        },
      },
      create: data,
      update: data,
    };
  }
}
