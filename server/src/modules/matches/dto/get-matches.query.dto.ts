import { MatchStatus } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { PageQueryDto } from '../../../common/dto/page-query.dto';

export class GetMatchesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ description: '팀 id' })
  @IsOptional()
  @IsString()
  teamId?: string;

  @ApiPropertyOptional({ description: '시즌 연도', example: 2026 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2020)
  seasonYear?: number;

  @ApiPropertyOptional({ description: 'Split 필터', example: 'SPRING' })
  @IsOptional()
  @IsString()
  split?: string;

  @ApiPropertyOptional({ description: 'Stage 필터', example: 'ROUND 1' })
  @IsOptional()
  @IsString()
  stage?: string;

  @ApiPropertyOptional({
    enum: MatchStatus,
    description: '경기 상태 필터',
  })
  @IsOptional()
  @IsEnum(MatchStatus)
  status?: MatchStatus;
}
