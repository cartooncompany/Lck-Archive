import { ApiProperty } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';

export class TeamSummaryResponseDto {
  @ApiProperty({ example: 'clx123team' })
  id: string;

  @ApiProperty({ example: 'T1' })
  name: string;

  @ApiProperty({ example: 'T1' })
  shortName: string;

  @ApiProperty({
    example: 'https://cdn.example.com/teams/t1.png',
    nullable: true,
  })
  logoUrl: string | null;

  @ApiProperty({ example: 1, nullable: true })
  rank: number | null;

  @ApiProperty({ example: 15 })
  wins: number;

  @ApiProperty({ example: 3 })
  losses: number;

  @ApiProperty({ example: 18 })
  setWins: number;

  @ApiProperty({ example: 8 })
  setLosses: number;

  @ApiProperty({ example: 10 })
  setDifferential: number;
}

export class TeamListResponseDto {
  @ApiProperty({ type: [TeamSummaryResponseDto] })
  items: TeamSummaryResponseDto[];

  @ApiProperty({ type: PaginationMetaDto })
  meta: PaginationMetaDto;
}
