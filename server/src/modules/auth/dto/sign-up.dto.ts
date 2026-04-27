import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class SignUpDto {
  @ApiProperty({
    example: 'faker',
    description: '서비스에서 사용할 닉네임',
  })
  @IsString()
  @IsNotEmpty()
  nickname: string;

  @ApiProperty({
    example: 'faker@example.com',
    description: '로그인에 사용할 이메일 주소',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'securePassword123!',
    description: '8자 이상 비밀번호',
    minLength: 8,
  })
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
