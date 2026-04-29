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

export class MatchGamePlayerStatResponseDto {
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
    type: TeamReferenceResponseDto,
    description: '선수가 속한 팀 정보',
  })
  team: TeamReferenceResponseDto;

  @ApiPropertyOptional({
    enum: PlayerPosition,
    example: PlayerPosition.MID,
    nullable: true,
    description: '해당 세트 포지션',
  })
  position: PlayerPosition | null;

  @ApiPropertyOptional({
    example: 'Ahri',
    nullable: true,
    description: '해당 세트 챔피언 이름',
  })
  championName: string | null;

  @ApiPropertyOptional({ example: 5, nullable: true })
  kills: number | null;

  @ApiPropertyOptional({ example: 1, nullable: true })
  deaths: number | null;

  @ApiPropertyOptional({ example: 7, nullable: true })
  assists: number | null;

  @ApiPropertyOptional({ example: 14500, nullable: true })
  totalGold: number | null;

  @ApiPropertyOptional({ example: 23500, nullable: true })
  damageDealt: number | null;

  @ApiPropertyOptional({ example: 10400, nullable: true })
  damageTaken: number | null;

  @ApiPropertyOptional({ example: 42.5, nullable: true })
  visionScore: number | null;

  @ApiPropertyOptional({ example: 12.0, nullable: true })
  kdaRatio: number | null;

  @ApiPropertyOptional({ example: 0.72, nullable: true })
  killParticipation: number | null;
}

export class MatchDraftActionResponseDto {
  @ApiProperty({
    example: 'ban',
    description: '밴픽 액션 타입',
  })
  type: string;

  @ApiProperty({
    example: '1',
    description: '밴픽 순서',
  })
  sequenceNumber: string;

  @ApiPropertyOptional({
    example: 'team-1',
    nullable: true,
    description: '밴픽 수행 주체 ID',
  })
  drafterId: string | null;

  @ApiPropertyOptional({
    example: 'team',
    nullable: true,
    description: '밴픽 수행 주체 타입',
  })
  drafterType: string | null;

  @ApiPropertyOptional({
    example: 'champion',
    nullable: true,
    description: '선택/금지 대상 타입',
  })
  draftableType: string | null;

  @ApiPropertyOptional({
    example: 'Azir',
    nullable: true,
    description: '선택/금지 대상 이름',
  })
  draftableName: string | null;
}

export class MatchGameResponseDto {
  @ApiProperty({
    example: 1,
    description: '세트 번호',
  })
  sequenceNumber: number;

  @ApiPropertyOptional({
    example: "Summoner's Rift",
    nullable: true,
    description: '맵 이름',
  })
  mapName: string | null;

  @ApiPropertyOptional({
    example: 'PT32M15S',
    nullable: true,
    description: '세트 길이. ISO 8601 duration 문자열',
  })
  duration: string | null;

  @ApiPropertyOptional({
    example: '2026-03-30T09:00:00.000Z',
    format: 'date-time',
    nullable: true,
    description: '세트 시작 시각',
  })
  startedAt: Date | null;

  @ApiPropertyOptional({
    type: TeamReferenceResponseDto,
    nullable: true,
    description: '세트 승리 팀',
  })
  winner: TeamReferenceResponseDto | null;

  @ApiProperty({
    type: [MatchGamePlayerStatResponseDto],
    description: '세트별 선수 통계',
  })
  playerStats: MatchGamePlayerStatResponseDto[];

  @ApiProperty({
    type: [MatchDraftActionResponseDto],
    description: '세트별 밴픽 액션',
  })
  draftActions: MatchDraftActionResponseDto[];
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

  @ApiProperty({
    type: [MatchGameResponseDto],
    description: '세트별 상세 정보',
  })
  games: MatchGameResponseDto[];
}
