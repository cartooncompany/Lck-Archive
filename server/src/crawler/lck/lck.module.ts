import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/prisma.module';
import { LckApiClient } from './client/lck-api.client';
import { LckSyncController } from './lck-sync.controller';
import { LckSyncJob } from './jobs/lck-sync.job';
import { LckMapper } from './mapper/lck.mapper';
import { LckParser } from './parser/lck.parser';

@Module({
  imports: [DatabaseModule],
  controllers: [LckSyncController],
  providers: [LckApiClient, LckParser, LckMapper, LckSyncJob],
  exports: [LckSyncJob],
})
export class LckCrawlerModule {}
