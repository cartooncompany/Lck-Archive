import { Controller, Post, UseGuards } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiSecurity,
  ApiServiceUnavailableResponse,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { ErrorResponseDto, ServiceUnavailableErrorResponseDto } from '../../common/responses/error-response.dto';
import { SyncSecretGuard } from '../guards/sync-secret.guard';
import { NewsSyncJob } from './jobs/news-sync.job';
import { NewsSyncResponseDto } from './responses/news-sync.response';

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
@Controller('crawler/news')
export class NewsSyncController {
  constructor(private readonly newsSyncJob: NewsSyncJob) {}

  @Post('sync')
  @ApiOperation({
    summary: '뉴스 데이터 수동 동기화',
    description:
      '외부 뉴스 소스로부터 LCK 관련 기사 데이터를 수집하고 데이터베이스에 반영합니다. X-Sync-Secret 헤더 필요.',
  })
  @ApiOkResponse({
    type: NewsSyncResponseDto,
    description: '동기화된 뉴스 기사 건수 요약',
  })
  sync() {
    return this.newsSyncJob.sync();
  }
}
