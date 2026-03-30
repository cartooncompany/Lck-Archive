import { ApiProperty } from '@nestjs/swagger';

export class HealthCheckResponseDto {
  @ApiProperty({ example: 'LCK Archive API' })
  service: string;

  @ApiProperty({ example: '0.1.0' })
  version: string;

  @ApiProperty({
    example: '2026-03-30T10:00:00.000Z',
    format: 'date-time',
  })
  timestamp: string;
}
