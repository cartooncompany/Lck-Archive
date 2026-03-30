import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class SignUpDto {
  @ApiProperty({ example: 'faker' })
  @IsString()
  @IsNotEmpty()
  nickname: string;

  @ApiProperty({ example: 'faker@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'securePassword123!' })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty({
    example: 'clx123team',
    description: '현재 응원 중인 팀 id',
  })
  @IsString()
  @IsNotEmpty()
  favoriteTeamId: string;
}
