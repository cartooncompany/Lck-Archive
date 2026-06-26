import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID, Length, Matches } from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({
    example: 'faker',
    description: '변경할 닉네임 (2~20자)',
  })
  @IsOptional()
  @IsString()
  @Length(2, 20)
  @Matches(/^[a-zA-Z0-9가-힣_]+$/, {
    message: '닉네임은 영문, 숫자, 한글, 밑줄(_)만 사용할 수 있습니다.',
  })
  nickname?: string;

  @ApiPropertyOptional({
    example: 'a1b2c3d4-...',
    description: '변경할 응원팀 id (UUID)',
    nullable: true,
  })
  @IsOptional()
  @IsUUID()
  favoriteTeamId?: string;
}
