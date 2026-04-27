import { ApiProperty } from '@nestjs/swagger';

export class NewsSyncResponseDto {
  @ApiProperty({
    example: 31,
    description: '동기화된 뉴스 기사 레코드 수',
  })
  newsArticles: number;
}
