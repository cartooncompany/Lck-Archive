import { NewsSource } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';

export class NewsSummaryResponseDto {
  @ApiProperty({
    example: 'clx123news',
    description: '뉴스 기사 고유 id',
  })
  id: string;

  @ApiProperty({
    example: 'LCK 정규 시즌 4월 1일 개막',
    description: '뉴스 기사 제목',
  })
  title: string;

  @ApiPropertyOptional({
    example: 'LCK 정규 시즌 개막을 앞두고 우승 후보가 공개됐다.',
    nullable: true,
    description: '기사 요약문',
  })
  summary: string | null;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/news/lck-opening.jpg',
    nullable: true,
    description: '뉴스 썸네일 이미지 URL',
  })
  thumbnailUrl: string | null;

  @ApiProperty({
    example: 'https://m.sports.naver.com/esports/article/382/0001265180',
    description: '원문 기사 URL',
  })
  articleUrl: string;

  @ApiPropertyOptional({
    example: '스포츠동아',
    nullable: true,
    description: '언론사 또는 발행처 이름',
  })
  publisher: string | null;

  @ApiProperty({
    enum: NewsSource,
    example: NewsSource.NAVER_ESPORTS,
    description: '뉴스 수집 출처',
  })
  source: NewsSource;

  @ApiPropertyOptional({
    example: '2026-03-30T09:47:50.000Z',
    format: 'date-time',
    nullable: true,
    description: '기사 게시 시각',
  })
  publishedAt: Date | null;

  @ApiPropertyOptional({
    example: '11 June 2024',
    nullable: true,
    description: '원문에 표시된 게시 시각 문자열',
  })
  publishedAtText: string | null;
}

export class NewsListResponseDto {
  @ApiProperty({
    type: [NewsSummaryResponseDto],
    description: '뉴스 기사 목록',
  })
  items: NewsSummaryResponseDto[];

  @ApiProperty({
    type: PaginationMetaDto,
    description: '페이지네이션 메타 정보',
  })
  meta: PaginationMetaDto;
}
