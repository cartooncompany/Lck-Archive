import { MatchStatus } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { PageQueryDto } from '../../../common/dto/page-query.dto';

export enum MatchSortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

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

  @ApiPropertyOptional({
    description: '이 시각 이후 경기만 조회',
    format: 'date-time',
    example: '2026-04-01T00:00:00.000Z',
  })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  from?: Date;

  @ApiPropertyOptional({
    description: '이 시각 이전 경기만 조회',
    format: 'date-time',
    example: '2026-04-30T23:59:59.999Z',
  })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  to?: Date;

  @ApiPropertyOptional({
    enum: MatchSortOrder,
    description: '경기 시간 정렬 순서',
    example: MatchSortOrder.ASC,
  })
  @IsOptional()
  @IsEnum(MatchSortOrder)
  sortOrder?: MatchSortOrder;
}
