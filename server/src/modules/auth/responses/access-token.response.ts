import { ApiProperty } from '@nestjs/swagger';

export class AccessTokenResponseDto {
  @ApiProperty({
    description: '새로 발급된 액세스 토큰',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.access-token.signature',
  })
  accessToken: string;

  @ApiProperty({
    example: '2026-03-30T13:00:00.000Z',
    description: '새로 발급된 액세스 토큰 만료 시각',
  })
  accessTokenExpiresAt: string;
}
