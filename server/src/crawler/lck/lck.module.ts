import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/prisma.module';
import { GridLckClient } from './client/grid-lck.client';
import { LckApiClient } from './client/lck-api.client';
import { LckSyncController } from './lck-sync.controller';
import { LckSyncJob } from './jobs/lck-sync.job';
import { LckMapper } from './mapper/lck.mapper';
import { GridLckParser } from './parser/grid-lck.parser';
import { LckParser } from './parser/lck.parser';
import { LckSnapshotService } from './services/lck-snapshot.service';

@Module({
  imports: [DatabaseModule],
  controllers: [LckSyncController],
  providers: [
    GridLckClient,
    GridLckParser,
    LckApiClient,
    LckParser,
    LckMapper,
    LckSnapshotService,
    LckSyncJob,
  ],
  exports: [LckSyncJob],
})
export class LckCrawlerModule {}
