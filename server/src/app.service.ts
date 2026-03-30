import { Injectable } from '@nestjs/common';
import { HealthCheckResponseDto } from './common/responses/health-check.response';

@Injectable()
export class AppService {
  getHealth(): HealthCheckResponseDto {
    return {
      service: 'LCK Archive API',
      version: '0.1.0',
      timestamp: new Date().toISOString(),
    };
  }
}
