import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../database/prisma.service';
import { LckSyncJob } from '../crawler/lck/jobs/lck-sync.job';
import { NewsSyncJob } from '../crawler/news/jobs/news-sync.job';

const DEFAULT_SYNC_LOG_RETENTION_DAYS = 30;

@Injectable()
export class SyncScheduler {
  private readonly logger = new Logger(SyncScheduler.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly lckSyncJob: LckSyncJob,
    private readonly newsSyncJob: NewsSyncJob,
    private readonly prisma: PrismaService,
  ) {}

  @Cron(process.env.LCK_SYNC_CRON || '*/5 * * * *', {
    name: 'lck-sync',
    timeZone: 'Asia/Seoul',
  })
  async handleLckSync(): Promise<void> {
    const enabled =
      this.configService.get<string>('LCK_SYNC_ENABLED') === 'true';

    if (!enabled) {
      return;
    }

    this.logger.log('Starting scheduled LCK data sync...');
    try {
      const result = await this.lckSyncJob.sync();
      this.logger.log(
        `LCK sync finished successfully. teams=${result.teams}, players=${result.players}, matches=${result.matches}`,
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`LCK sync scheduled task failed: ${message}`);
    }
  }

  @Cron(process.env.NEWS_SYNC_CRON || '*/10 * * * *', {
    name: 'news-sync',
    timeZone: 'Asia/Seoul',
  })
  async handleNewsSync(): Promise<void> {
    const enabled =
      this.configService.get<string>('NEWS_SYNC_ENABLED') === 'true';

    if (!enabled) {
      return;
    }

    this.logger.log('Starting scheduled News sync...');
    try {
      const result = await this.newsSyncJob.sync();
      this.logger.log(
        `News sync finished successfully. articles=${result.newsArticles}`,
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`News sync scheduled task failed: ${message}`);
    }
  }

  /**
   * 매일 새벽 3시(KST), 보존 기간이 지난 SyncJobLog를 정리한다.
   * 동기화 로그는 무한 누적되므로 주기적으로 오래된 항목을 삭제한다.
   * 보존 일수는 SYNC_LOG_RETENTION_DAYS로 조정한다. (0이면 정리 비활성화)
   */
  @Cron(CronExpression.EVERY_DAY_AT_3AM, {
    name: 'sync-log-cleanup',
    timeZone: 'Asia/Seoul',
  })
  async handleSyncLogCleanup(): Promise<void> {
    const retentionDays = this.resolveRetentionDays();
    if (retentionDays === 0) {
      return;
    }

    const cutoff = new Date(Date.now() - retentionDays * 24 * 60 * 60 * 1000);

    try {
      const { count } = await this.prisma.syncJobLog.deleteMany({
        where: { createdAt: { lt: cutoff } },
      });
      if (count > 0) {
        this.logger.log(
          `Sync log cleanup removed ${count} entries older than ${retentionDays} days.`,
        );
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Sync log cleanup failed: ${message}`);
    }
  }

  private resolveRetentionDays(): number {
    const raw = this.configService.get<string>('SYNC_LOG_RETENTION_DAYS');
    const parsed = Number(raw);
    return Number.isInteger(parsed) && parsed >= 0
      ? parsed
      : DEFAULT_SYNC_LOG_RETENTION_DAYS;
  }
}
