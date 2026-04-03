import { NewsSource } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';

export class NewsSummaryResponseDto {
  @ApiProperty({ example: 'clx123news' })
  id: string;

  @ApiProperty({ example: 'LCK 정규 시즌 4월 1일 개막' })
  title: string;

  @ApiPropertyOptional({
    example: 'LCK 정규 시즌 개막을 앞두고 우승 후보가 공개됐다.',
    nullable: true,
  })
  summary: string | null;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/news/lck-opening.jpg',
    nullable: true,
  })
  thumbnailUrl: string | null;

  @ApiProperty({
    example: 'https://m.sports.naver.com/esports/article/382/0001265180',
  })
  articleUrl: string;

  @ApiPropertyOptional({
    example: '스포츠동아',
    nullable: true,
  })
  publisher: string | null;

  @ApiProperty({
    enum: NewsSource,
    example: NewsSource.NAVER_ESPORTS,
  })
  source: NewsSource;

  @ApiPropertyOptional({
    example: '2026-03-30T09:47:50.000Z',
    format: 'date-time',
    nullable: true,
  })
  publishedAt: Date | null;

  @ApiPropertyOptional({
    example: '11 June 2024',
    nullable: true,
  })
  publishedAtText: string | null;
}

export class NewsListResponseDto {
  @ApiProperty({ type: [NewsSummaryResponseDto] })
  items: NewsSummaryResponseDto[];

  @ApiProperty({ type: PaginationMetaDto })
  meta: PaginationMetaDto;
}
