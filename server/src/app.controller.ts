import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service';
import { HealthCheckResponseDto } from './common/responses/health-check.response';

@ApiTags('Health')
@Controller('health')
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({
    summary: '서버 상태 조회',
    description:
      '서버 기동 여부와 현재 배포된 애플리케이션 버전 정보를 반환합니다.',
  })
  @ApiOkResponse({
    type: HealthCheckResponseDto,
    description: '현재 서버 상태와 버전 정보',
  })
  getHealth(): HealthCheckResponseDto {
    return this.appService.getHealth();
  }
}
