import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PlayerSummaryResponseDto } from './player-summary.response';

export class PlayerStatsResponseDto {
  @ApiProperty({ example: 42, description: '총 출전 세트 수' })
  gamesPlayed: number;

  @ApiProperty({ example: 150, description: '통산 총 킬' })
  totalKills: number;

  @ApiProperty({ example: 80, description: '통산 총 데스' })
  totalDeaths: number;

  @ApiProperty({ example: 220, description: '통산 총 어시스트' })
  totalAssists: number;

  @ApiProperty({ example: 3.57, description: '평균 킬수 (세트당)' })
  avgKills: number;

  @ApiProperty({ example: 1.9, description: '평균 데스수 (세트당)' })
  avgDeaths: number;

  @ApiProperty({ example: 5.24, description: '평균 어시스트수 (세트당)' })
  avgAssists: number;

  @ApiProperty({ example: 4.63, description: '평균 KDA ratio' })
  avgKda: number;
}

export class PlayerMatchAppearanceResponseDto {
  @ApiProperty({ example: '2026-06-23T00:00:00.000Z', description: '경기 일시' })
  playedAt: Date;

  @ApiProperty({ example: 'Gen.G Esports', description: '상대 팀명' })
  opponent: string;

  @ApiProperty({ example: '승', description: '경기 결과 (승/패)' })
  result: string;

  @ApiProperty({ example: '3 / 1 / 8 (Azir)', description: '선수 개인 성적' })
  performance: string;
}

export class PlayerDetailResponseDto extends PlayerSummaryResponseDto {
  @ApiPropertyOptional({
    example: 'Lee Sang-hyeok',
    nullable: true,
    description: '선수 본명',
  })
  realName: string | null;

  @ApiPropertyOptional({
    example: 'KR',
    nullable: true,
    description: '국적 코드',
  })
  nationality: string | null;

  @ApiPropertyOptional({
    example: '1996-05-07T00:00:00.000Z',
    format: 'date-time',
    nullable: true,
    description: '생년월일',
  })
  birthDate: Date | null;

  @ApiProperty({
    type: PlayerStatsResponseDto,
    description: '선수 통산/평균 통계 기록',
  })
  stats: PlayerStatsResponseDto;

  @ApiProperty({
    type: [PlayerMatchAppearanceResponseDto],
    description: '선수 최근 경기 출전 기록',
  })
  recentAppearances: PlayerMatchAppearanceResponseDto[];

}

