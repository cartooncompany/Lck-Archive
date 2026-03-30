import { PlayerPosition } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';
import { MatchSummaryResponseDto } from './match-summary.response';

export class MatchParticipantResponseDto {
  @ApiProperty({ example: 'clx123player' })
  playerId: string;

  @ApiProperty({ example: 'Faker' })
  playerName: string;

  @ApiProperty({ enum: PlayerPosition, example: PlayerPosition.MID })
  position: PlayerPosition;

  @ApiProperty({ default: true })
  isStarter: boolean;

  @ApiProperty({ type: TeamReferenceResponseDto })
  team: TeamReferenceResponseDto;
}

export class MatchDetailResponseDto extends MatchSummaryResponseDto {
  @ApiPropertyOptional({ example: 'MATCH-101', nullable: true })
  matchNumber: string | null;

  @ApiPropertyOptional({
    example: 'https://vod.example.com/lck/match-101',
    nullable: true,
  })
  vodUrl: string | null;

  @ApiProperty({ type: [MatchParticipantResponseDto] })
  participants: MatchParticipantResponseDto[];
}
