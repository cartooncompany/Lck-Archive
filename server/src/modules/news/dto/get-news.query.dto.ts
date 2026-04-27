import { NewsSource } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PageQueryDto } from '../../../common/dto/page-query.dto';

export enum NewsSortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export class GetNewsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: NewsSource,
    description: '뉴스 출처 필터',
    example: NewsSource.NAVER_ESPORTS,
  })
  @IsOptional()
  @IsEnum(NewsSource)
  source?: NewsSource;

  @ApiPropertyOptional({
    description: '제목, 요약, 언론사 검색',
    example: 'T1',
  })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({
    enum: NewsSortOrder,
    description: '게시 시각 정렬 순서',
    example: NewsSortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(NewsSortOrder)
  sortOrder: NewsSortOrder = NewsSortOrder.DESC;
}
