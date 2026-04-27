import { Controller, Post } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ServiceUnavailableErrorResponseDto } from '../../common/responses/error-response.dto';
import { LckSyncJob } from './jobs/lck-sync.job';
import { LckSyncResponseDto } from './responses/lck-sync.response';

@ApiTags('Crawler')
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
      '외부 LCK 데이터 소스로부터 팀, 선수, 경기 데이터를 수집하고 데이터베이스에 반영합니다.',
  })
  @ApiOkResponse({
    type: LckSyncResponseDto,
    description: '동기화된 팀, 선수, 경기 건수 요약',
  })
  sync() {
    return this.lckSyncJob.sync();
  }
}
