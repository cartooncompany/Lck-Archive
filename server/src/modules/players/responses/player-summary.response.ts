import { PlayerPosition } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';

export class PlayerSummaryResponseDto {
  @ApiProperty({ example: 'clx123player' })
  id: string;

  @ApiProperty({ example: 'Faker' })
  name: string;

  @ApiProperty({ enum: PlayerPosition, example: PlayerPosition.MID })
  position: PlayerPosition;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/players/faker.png',
    nullable: true,
  })
  profileImageUrl: string | null;

  @ApiProperty({ example: 10 })
  recentMatchCount: number;

  @ApiPropertyOptional({
    type: TeamReferenceResponseDto,
    nullable: true,
  })
  team: TeamReferenceResponseDto | null;
}

export class PlayerListResponseDto {
  @ApiProperty({ type: [PlayerSummaryResponseDto] })
  items: PlayerSummaryResponseDto[];

  @ApiProperty({ type: PaginationMetaDto })
  meta: PaginationMetaDto;
}
