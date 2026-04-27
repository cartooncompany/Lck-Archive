import { ApiProperty } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';

export class TeamSummaryResponseDto {
  @ApiProperty({
    example: 'clx123team',
    description: '팀 고유 id',
  })
  id: string;

  @ApiProperty({
    example: 'T1',
    description: '팀명',
  })
  name: string;

  @ApiProperty({
    example: 'T1',
    description: '팀 약칭',
  })
  shortName: string;

  @ApiProperty({
    example: 'https://cdn.example.com/teams/t1.png',
    nullable: true,
    description: '팀 로고 이미지 URL',
  })
  logoUrl: string | null;

  @ApiProperty({
    example: 1,
    nullable: true,
    description: '현재 순위. 미집계 시 null',
  })
  rank: number | null;

  @ApiProperty({
    example: 15,
    description: '승리 수',
  })
  wins: number;

  @ApiProperty({
    example: 3,
    description: '패배 수',
  })
  losses: number;

  @ApiProperty({
    example: 18,
    description: '세트 승리 수',
  })
  setWins: number;

  @ApiProperty({
    example: 8,
    description: '세트 패배 수',
  })
  setLosses: number;

  @ApiProperty({
    example: 10,
    description: '세트 득실차',
  })
  setDifferential: number;
}

export class TeamListResponseDto {
  @ApiProperty({
    type: [TeamSummaryResponseDto],
    description: '팀 목록',
  })
  items: TeamSummaryResponseDto[];

  @ApiProperty({
    type: PaginationMetaDto,
    description: '페이지네이션 메타 정보',
  })
  meta: PaginationMetaDto;
}
