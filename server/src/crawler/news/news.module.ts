import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/prisma.module';
import { NewsScraperClient } from './client/news-scraper.client';
import { NewsSyncJob } from './jobs/news-sync.job';
import { NewsParser } from './parser/news.parser';
import { NewsSyncController } from './news-sync.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [NewsSyncController],
  providers: [NewsParser, NewsScraperClient, NewsSyncJob],
  exports: [NewsSyncJob],
})
export class NewsCrawlerModule {}
