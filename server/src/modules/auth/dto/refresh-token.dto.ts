import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RefreshTokenDto {
  @ApiProperty({
    description: '로그인 시 발급된 리프레시 토큰',
  })
  @IsString()
  @IsNotEmpty()
  refreshToken: string;
}
