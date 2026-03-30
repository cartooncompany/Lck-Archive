import { ApiProperty } from '@nestjs/swagger';
import { TeamSummaryResponseDto } from './team-summary.response';

export enum RecentFormResult {
  WIN = 'W',
  LOSS = 'L',
}

export class TeamDetailResponseDto extends TeamSummaryResponseDto {
  @ApiProperty({
    enum: RecentFormResult,
    isArray: true,
    example: ['W', 'W', 'L', 'W', 'L'],
  })
  recentForm: RecentFormResult[];
}
