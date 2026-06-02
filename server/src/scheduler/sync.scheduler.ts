import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron } from '@nestjs/schedule';
import { LckSyncJob } from '../crawler/lck/jobs/lck-sync.job';
import { NewsSyncJob } from '../crawler/news/jobs/news-sync.job';

@Injectable()
export class SyncScheduler {
  private readonly logger = new Logger(SyncScheduler.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly lckSyncJob: LckSyncJob,
    private readonly newsSyncJob: NewsSyncJob,
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
      this.logger.log(`News sync finished successfully. articles=${result.newsArticles}`);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`News sync scheduled task failed: ${message}`);
    }
  }
}
