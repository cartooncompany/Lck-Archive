import { ApiProperty } from '@nestjs/swagger';

export class HealthCheckResponseDto {
  @ApiProperty({
    example: 'LCK Archive API',
    description: '서비스 이름',
  })
  service: string;

  @ApiProperty({
    example: '0.1.0',
    description: '현재 배포된 서비스 버전',
  })
  version: string;

  @ApiProperty({
    example: '2026-03-30T10:00:00.000Z',
    format: 'date-time',
    description: '응답 생성 시각',
  })
  timestamp: string;
}
