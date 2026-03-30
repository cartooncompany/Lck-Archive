import { ApiProperty } from '@nestjs/swagger';

export class UserProfileResponseDto {
  @ApiProperty({ example: 'faker' })
  nickname: string;

  @ApiProperty({ example: 'faker@example.com' })
  email: string;
}
