import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, Max, Min } from 'class-validator';

export class GetRecentMatchesQueryDto {
  @ApiPropertyOptional({
    description: '가져올 최근 경기 결과 개수 (기본값: 5)',
    example: 5,
    minimum: 1,
    maximum: 50,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 5;
}
