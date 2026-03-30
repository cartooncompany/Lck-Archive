import { ApiProperty } from '@nestjs/swagger';

export class AccessTokenResponseDto {
  @ApiProperty()
  accessToken: string;

  @ApiProperty({
    example: '2026-03-30T13:00:00.000Z',
    description: '새로 발급된 액세스 토큰 만료 시각',
  })
  accessTokenExpiresAt: string;
}
