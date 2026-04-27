import { PlayerPosition } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';
import { MatchSummaryResponseDto } from './match-summary.response';

export class MatchParticipantResponseDto {
  @ApiProperty({
    example: 'clx123player',
    description: '선수 고유 id',
  })
  playerId: string;

  @ApiProperty({
    example: 'Faker',
    description: '선수 이름',
  })
  playerName: string;

  @ApiProperty({
    enum: PlayerPosition,
    example: PlayerPosition.MID,
    description: '선수 포지션',
  })
  position: PlayerPosition;

  @ApiProperty({
    default: true,
    description: '선발 출전 여부',
  })
  isStarter: boolean;

  @ApiProperty({
    type: TeamReferenceResponseDto,
    description: '선수가 속한 팀 정보',
  })
  team: TeamReferenceResponseDto;
}

export class MatchDetailResponseDto extends MatchSummaryResponseDto {
  @ApiPropertyOptional({
    example: 'MATCH-101',
    nullable: true,
    description: '대회 또는 방송 기준 경기 번호',
  })
  matchNumber: string | null;

  @ApiPropertyOptional({
    example: 'https://vod.example.com/lck/match-101',
    nullable: true,
    description: 'VOD 다시보기 URL',
  })
  vodUrl: string | null;

  @ApiProperty({
    type: [MatchParticipantResponseDto],
    description: '출전 선수 목록',
  })
  participants: MatchParticipantResponseDto[];
}
