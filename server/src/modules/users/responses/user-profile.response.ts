import { ApiProperty } from '@nestjs/swagger';

export class UserProfileResponseDto {
  @ApiProperty({
    example: 'faker',
    description: '사용자 닉네임',
  })
  nickname: string;

  @ApiProperty({
    example: 'faker@example.com',
    description: '사용자 이메일 주소',
  })
  email: string;
}
