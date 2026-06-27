import { Controller, Post, UseGuards } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiSecurity,
  ApiServiceUnavailableResponse,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import {
  ErrorResponseDto,
  ServiceUnavailableErrorResponseDto,
} from '../../common/responses/error-response.dto';
import { SyncSecretGuard } from '../guards/sync-secret.guard';
import { LckSyncJob } from './jobs/lck-sync.job';
import { LckSyncResponseDto } from './responses/lck-sync.response';

@ApiTags('Crawler')
@ApiSecurity('sync-secret')
@UseGuards(SyncSecretGuard)
@ApiUnauthorizedResponse({
  description: 'X-Sync-Secret 헤더가 없거나 올바르지 않습니다.',
  type: ErrorResponseDto,
})
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('crawler/lck')
export class LckSyncController {
  constructor(private readonly lckSyncJob: LckSyncJob) {}

  @Post('sync')
  @ApiOperation({
    summary: 'LCK 데이터 수동 동기화',
    description:
      '외부 LCK 데이터 소스로부터 팀, 선수, 경기 데이터를 수집하고 데이터베이스에 반영합니다. X-Sync-Secret 헤더 필요.',
  })
  @ApiOkResponse({
    type: LckSyncResponseDto,
    description: '동기화된 팀, 선수, 경기 건수 요약',
  })
  sync() {
    return this.lckSyncJob.sync();
  }
}
