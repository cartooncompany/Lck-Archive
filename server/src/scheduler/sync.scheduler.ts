import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
import { LckSyncJob } from '../crawler/lck/jobs/lck-sync.job';

@Injectable()
export class SyncScheduler {
  private readonly logger = new Logger(SyncScheduler.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly lckSyncJob: LckSyncJob,
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
}
