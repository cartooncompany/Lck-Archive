import { ApiProperty } from '@nestjs/swagger';
import { UserProfileResponseDto } from '../../users/responses/user-profile.response';

export class AuthSessionResponseDto {
  @ApiProperty()
  accessToken: string;

  @ApiProperty({
    example: '2026-03-30T13:00:00.000Z',
    description: '액세스 토큰 만료 시각',
  })
  accessTokenExpiresAt: string;

  @ApiProperty()
  refreshToken: string;

  @ApiProperty({
    example: '2026-03-31T12:00:00.000Z',
    description: '리프레시 토큰 만료 시각',
  })
  refreshTokenExpiresAt: string;

  @ApiProperty({ type: UserProfileResponseDto })
  user: UserProfileResponseDto;
}
