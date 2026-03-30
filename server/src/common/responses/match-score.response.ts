import { ApiProperty } from '@nestjs/swagger';

export class MatchScoreResponseDto {
  @ApiProperty({ example: 2 })
  home: number;

  @ApiProperty({ example: 1 })
  away: number;
}
