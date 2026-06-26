import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Matches,
  MinLength,
} from 'class-validator';

export class SignUpDto {
  @ApiProperty({
    example: 'faker',
    description: '서비스에서 사용할 닉네임 (2~20자, 영문/숫자/한글/밑줄)',
    minLength: 2,
    maxLength: 20,
  })
  @IsString()
  @IsNotEmpty()
  @Length(2, 20)
  @Matches(/^[a-zA-Z0-9가-힣_]+$/, {
    message: '닉네임은 영문, 숫자, 한글, 밑줄(_)만 사용할 수 있습니다.',
  })
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

  @ApiPropertyOptional({
    example: 'clx123team',
    description: '현재 응원 중인 팀 id (선택 사항)',
    nullable: true,
  })
  @IsOptional()
  @IsUUID()
  favoriteTeamId?: string | null;
}
