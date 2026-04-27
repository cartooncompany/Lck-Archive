import { ApiProperty } from '@nestjs/swagger';

export class PaginationMetaDto {
  @ApiProperty({
    example: 1,
    description: '현재 페이지 번호',
  })
  page: number;

  @ApiProperty({
    example: 20,
    description: '페이지당 데이터 수',
  })
  limit: number;

  @ApiProperty({
    example: 42,
    description: '조건에 맞는 전체 데이터 수',
  })
  total: number;

  @ApiProperty({
    example: 3,
    description: '전체 페이지 수',
  })
  totalPages: number;
}
