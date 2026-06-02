import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../database/prisma.service';
import { NewsScraperClient } from '../client/news-scraper.client';
import { ScrapedNewsArticle } from '../types/news-source.types';

const DEFAULT_NEWS_LIVE_REFRESH_INTERVAL_MS = 10 * 60 * 1000;

@Injectable()
export class NewsSyncJob {
  private readonly logger = new Logger(NewsSyncJob.name);
  private runningSync?: Promise<{ newsArticles: number }>;

  constructor(
    private readonly prisma: PrismaService,
    private readonly newsScraperClient: NewsScraperClient,
    private readonly configService: ConfigService,
  ) {}

  async sync(): Promise<{ newsArticles: number }> {
    if (this.runningSync) {
      return this.runningSync;
    }

    this.runningSync = this.runSync().finally(() => {
      this.runningSync = undefined;
    });

    return this.runningSync;
  }

  async syncIfStale(): Promise<void> {
    if (!(await this.shouldRefresh())) {
      return;
    }

    try {
      await this.sync();
    } catch (error) {
      const articleCount = await this.prisma.newsArticle.count();

      if (articleCount > 0) {
        const message =
          error instanceof Error ? error.message : 'Unknown sync error';
        this.logger.warn(
          `News live refresh failed. Serving existing cached data: ${message}`,
        );
        return;
      }

      throw error;
    }
  }

  private async runSync(): Promise<{ newsArticles: number }> {
    const log = await this.prisma.syncJobLog.create({
      data: {
        jobName: 'news-sync',
        status: 'RUNNING',
      },
    });

    try {
      const articles = await this.newsScraperClient.fetchLatestNews();

      const articleExternalIds = articles.map((a) => a.externalId);
      const existingArticles = await this.prisma.newsArticle.findMany({
        where: {
          externalId: {
            in: articleExternalIds,
          },
        },
        select: {
          externalId: true,
        },
      });

      const existingSet = new Set(existingArticles.map((ea) => ea.externalId));
      const newArticles = articles.filter((a) => !existingSet.has(a.externalId));

      if (newArticles.length > 0) {
        await this.prisma.newsArticle.createMany({
          data: newArticles.map((article) => ({
            title: article.title,
            summary: article.summary,
            thumbnailUrl: article.thumbnailUrl,
            articleUrl: article.articleUrl,
            publisher: article.publisher,
            externalSource: article.externalSource,
            externalId: article.externalId,
            publishedAt: article.publishedAt,
            publishedAtText: article.publishedAtText,
          })),
        });
        this.logger.log(`News sync optimized: Saved ${newArticles.length} new articles.`);
      } else {
        this.logger.log('News sync optimized: No new articles to save.');
      }

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

  private async shouldRefresh(): Promise<boolean> {
    const [articleCount, latestSuccess] = await Promise.all([
      this.prisma.newsArticle.count(),
      this.prisma.syncJobLog.findFirst({
        where: {
          jobName: 'news-sync',
          status: 'SUCCESS',
        },
        orderBy: {
          startedAt: 'desc',
        },
        select: {
          startedAt: true,
          finishedAt: true,
        },
      }),
    ]);

    if (articleCount === 0) {
      return true;
    }

    const refreshIntervalMs = this.parseNonNegativeInt(
      this.configService.get<string>('NEWS_LIVE_REFRESH_INTERVAL_MS'),
      DEFAULT_NEWS_LIVE_REFRESH_INTERVAL_MS,
    );

    if (refreshIntervalMs === 0) {
      return false;
    }

    const refreshedAt = latestSuccess?.finishedAt ?? latestSuccess?.startedAt;
    if (!refreshedAt) {
      return true;
    }

    return Date.now() - refreshedAt.getTime() > refreshIntervalMs;
  }

  private parseNonNegativeInt(
    value: string | undefined,
    fallback: number,
  ): number {
    const parsed = Number(value);
    return Number.isInteger(parsed) && parsed >= 0 ? parsed : fallback;
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
