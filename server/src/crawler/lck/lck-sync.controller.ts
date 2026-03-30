import { Controller, Post } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { LckSyncJob } from './jobs/lck-sync.job';

@ApiTags('Crawler')
@Controller('crawler/lck')
export class LckSyncController {
  constructor(private readonly lckSyncJob: LckSyncJob) {}

  @Post('sync')
  @ApiOperation({ summary: 'LCK 데이터 수동 동기화' })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        teams: { type: 'number', example: 10 },
        players: { type: 'number', example: 60 },
        matches: { type: 'number', example: 90 },
      },
    },
  })
  sync() {
    return this.lckSyncJob.sync();
  }
}
