import { Module } from '@nestjs/common';
import { LckCrawlerModule } from './lck/lck.module';
import { NewsCrawlerModule } from './news/news.module';

@Module({
  imports: [LckCrawlerModule, NewsCrawlerModule],
  exports: [LckCrawlerModule, NewsCrawlerModule],
})
export class CrawlerModule {}
