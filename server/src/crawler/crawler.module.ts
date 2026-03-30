import { Module } from '@nestjs/common';
import { LckCrawlerModule } from './lck/lck.module';

@Module({
  imports: [LckCrawlerModule],
  exports: [LckCrawlerModule],
})
export class CrawlerModule {}
