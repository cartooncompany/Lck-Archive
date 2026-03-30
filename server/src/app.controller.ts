import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service';
import { HealthCheckResponseDto } from './common/responses/health-check.response';

@ApiTags('Health')
@Controller('health')
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: '서버 상태 조회' })
  @ApiOkResponse({ type: HealthCheckResponseDto })
  getHealth(): HealthCheckResponseDto {
    return this.appService.getHealth();
  }
}
