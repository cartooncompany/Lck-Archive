import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ErrorResponseDto {
  @ApiProperty({
    example: 404,
    description: 'HTTP 상태 코드',
  })
  statusCode: number;

  @ApiProperty({
    example: 'Team not found: clx123team',
    description: '오류 원인을 설명하는 메시지',
  })
  message: string;

  @ApiProperty({
    example: 'Not Found',
    description: 'HTTP 오류 이름',
  })
  error: string;

  @ApiProperty({
    example: '/api/teams/clx123team',
    description: '오류가 발생한 요청 경로',
  })
  path: string;

  @ApiProperty({
    example: '2026-04-25T12:00:00.000Z',
    format: 'date-time',
    description: '오류 응답 생성 시각',
  })
  timestamp: string;
}

export class ValidationErrorResponseDto {
  @ApiProperty({
    example: 400,
    description: 'HTTP 상태 코드',
  })
  statusCode: number;

  @ApiProperty({
    type: [String],
    example: [
      'email must be an email',
      'password must be longer than or equal to 8 characters',
    ],
    description: '검증에 실패한 요청 필드별 오류 메시지 목록',
  })
  message: string[];

  @ApiProperty({
    example: 'Bad Request',
    description: 'HTTP 오류 이름',
  })
  error: string;

  @ApiProperty({
    example: '/api/auth/login',
    description: '오류가 발생한 요청 경로',
  })
  path: string;

  @ApiProperty({
    example: '2026-04-25T12:00:00.000Z',
    format: 'date-time',
    description: '오류 응답 생성 시각',
  })
  timestamp: string;
}

export class ServiceUnavailableErrorResponseDto extends ErrorResponseDto {
  @ApiPropertyOptional({
    example: 'Database connection failed',
    description: '장애 분석을 위한 추가 상세 정보',
    nullable: true,
  })
  details?: string;
}
