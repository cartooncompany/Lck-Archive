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
    description: '최근 5경기 기준 승패 흐름',
  })
  recentForm: RecentFormResult[];
}
