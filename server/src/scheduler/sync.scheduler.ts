import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
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

  @Cron(CronExpression.EVERY_6_HOURS, {
    name: 'lck-sync',
    timeZone: 'Asia/Seoul',
  })
  async handleLckSync(): Promise<void> {
    const enabled =
      this.configService.get<string>('LCK_SYNC_ENABLED') === 'true';

    if (!enabled) {
      return;
    }

    const result = await this.lckSyncJob.sync();

    this.logger.log(
      `LCK sync finished. teams=${result.teams}, players=${result.players}, matches=${result.matches}`,
    );
  }

  @Cron(CronExpression.EVERY_HOUR, {
    name: 'news-sync',
    timeZone: 'Asia/Seoul',
  })
  async handleNewsSync(): Promise<void> {
    const enabled =
      this.configService.get<string>('NEWS_SYNC_ENABLED') === 'true';

    if (!enabled) {
      return;
    }

    const result = await this.newsSyncJob.sync();

    this.logger.log(`News sync finished. articles=${result.newsArticles}`);
  }
}
