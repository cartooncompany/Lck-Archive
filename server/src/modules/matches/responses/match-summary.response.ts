import { MatchStatus } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { MatchScoreResponseDto } from '../../../common/responses/match-score.response';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';

export class MatchSummaryResponseDto {
  @ApiProperty({ example: 'clx123match' })
  id: string;

  @ApiProperty({
    example: '2026-03-30T09:00:00.000Z',
    format: 'date-time',
  })
  scheduledAt: Date;

  @ApiProperty({ example: 2026 })
  seasonYear: number;

  @ApiProperty({ example: 'SPRING' })
  split: string;

  @ApiProperty({ example: 'ROUND 1' })
  stage: string;

  @ApiProperty({ enum: MatchStatus, example: MatchStatus.COMPLETED })
  status: MatchStatus;

  @ApiProperty({ type: TeamReferenceResponseDto })
  homeTeam: TeamReferenceResponseDto;

  @ApiProperty({ type: TeamReferenceResponseDto })
  awayTeam: TeamReferenceResponseDto;

  @ApiProperty({ type: MatchScoreResponseDto })
  score: MatchScoreResponseDto;

  @ApiPropertyOptional({
    type: TeamReferenceResponseDto,
    nullable: true,
  })
  winner: TeamReferenceResponseDto | null;
}

export class MatchListResponseDto {
  @ApiProperty({ type: [MatchSummaryResponseDto] })
  items: MatchSummaryResponseDto[];

  @ApiProperty({ type: PaginationMetaDto })
  meta: PaginationMetaDto;
}
