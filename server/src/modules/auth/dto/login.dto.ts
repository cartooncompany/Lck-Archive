import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'faker@example.com',
    description: '가입한 이메일 주소',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'securePassword123!',
    description: '가입 시 사용한 비밀번호',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  password: string;
}
