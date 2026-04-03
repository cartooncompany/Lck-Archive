import { Module } from '@nestjs/common';
import { CrawlerModule } from '../crawler/crawler.module';
import { SyncScheduler } from './sync.scheduler';

@Module({
  imports: [CrawlerModule],
  providers: [SyncScheduler],
})
export class SyncSchedulerModule {}