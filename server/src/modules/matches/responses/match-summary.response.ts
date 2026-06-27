import { MatchStatus } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { MatchScoreResponseDto } from '../../../common/responses/match-score.response';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';

export class MatchSummaryResponseDto {
  @ApiProperty({
    example: 'clx123match',
    description: '경기 고유 id',
  })
  id: string;

  @ApiProperty({
    example: '2026-03-30T09:00:00.000Z',
    format: 'date-time',
    description: '경기 예정 시각 또는 시작 시각',
  })
  scheduledAt: Date;

  @ApiProperty({
    example: 2026,
    description: '시즌 연도',
  })
  seasonYear: number;

  @ApiProperty({
    example: 'SPRING',
    description: '시즌 split 이름',
  })
  split: string;

  @ApiProperty({
    example: 'ROUND 1',
    description: '시즌 stage 이름',
  })
  stage: string;

  @ApiProperty({
    enum: MatchStatus,
    example: MatchStatus.COMPLETED,
    description: '경기 진행 상태',
  })
  status: MatchStatus;

  @ApiProperty({
    type: TeamReferenceResponseDto,
    description: '홈 팀 정보',
  })
  homeTeam: TeamReferenceResponseDto;

  @ApiProperty({
    type: TeamReferenceResponseDto,
    description: '어웨이 팀 정보',
  })
  awayTeam: TeamReferenceResponseDto;

  @ApiProperty({
    type: MatchScoreResponseDto,
    description: '현재까지 기록된 세트 스코어',
  })
  score: MatchScoreResponseDto;

  @ApiPropertyOptional({
    type: TeamReferenceResponseDto,
    nullable: true,
    description: '승자 팀 정보. 경기 미종료 시 null',
  })
  winner: TeamReferenceResponseDto | null;
}

export class MatchListResponseDto {
  @ApiProperty({
    type: [MatchSummaryResponseDto],
    description: '경기 목록',
  })
  items: MatchSummaryResponseDto[];

  @ApiProperty({
    type: PaginationMetaDto,
    description: '페이지네이션 메타 정보',
  })
  meta: PaginationMetaDto;
}
