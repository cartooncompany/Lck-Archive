import { ApiProperty } from '@nestjs/swagger';

export class LckSyncResponseDto {
  @ApiProperty({
    example: 10,
    description: '동기화된 팀 레코드 수',
  })
  teams: number;

  @ApiProperty({
    example: 60,
    description: '동기화된 선수 레코드 수',
  })
  players: number;

  @ApiProperty({
    example: 90,
    description: '동기화된 경기 레코드 수',
  })
  matches: number;
}
