import { ApiProperty } from '@nestjs/swagger';
import { UserProfileResponseDto } from '../../users/responses/user-profile.response';

export class AuthSessionResponseDto {
  @ApiProperty({
    description: '인증이 필요한 요청에 사용할 액세스 토큰',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.access-token.signature',
  })
  accessToken: string;

  @ApiProperty({
    example: '2026-03-30T13:00:00.000Z',
    description: '액세스 토큰 만료 시각',
  })
  accessTokenExpiresAt: string;

  @ApiProperty({
    description: '액세스 토큰 재발급에 사용할 리프레시 토큰',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh-token.signature',
  })
  refreshToken: string;

  @ApiProperty({
    example: '2026-03-31T12:00:00.000Z',
    description: '리프레시 토큰 만료 시각',
  })
  refreshTokenExpiresAt: string;

  @ApiProperty({
    type: UserProfileResponseDto,
    description: '로그인된 사용자 기본 정보',
  })
  user: UserProfileResponseDto;
}
