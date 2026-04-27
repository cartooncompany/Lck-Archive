import { PlayerPosition } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationMetaDto } from '../../../common/responses/pagination-meta.dto';
import { TeamReferenceResponseDto } from '../../../common/responses/team-reference.response';

export class PlayerSummaryResponseDto {
  @ApiProperty({
    example: 'clx123player',
    description: '선수 고유 id',
  })
  id: string;

  @ApiProperty({
    example: 'Faker',
    description: '선수명',
  })
  name: string;

  @ApiProperty({
    enum: PlayerPosition,
    example: PlayerPosition.MID,
    description: '주 포지션',
  })
  position: PlayerPosition;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/players/faker.png',
    nullable: true,
    description: '프로필 이미지 URL',
  })
  profileImageUrl: string | null;

  @ApiProperty({
    example: 10,
    description: '최근 집계된 경기 수',
  })
  recentMatchCount: number;

  @ApiPropertyOptional({
    type: TeamReferenceResponseDto,
    nullable: true,
    description: '현재 소속 팀 정보. 무소속 또는 미매핑 시 null',
  })
  team: TeamReferenceResponseDto | null;
}

export class PlayerListResponseDto {
  @ApiProperty({
    type: [PlayerSummaryResponseDto],
    description: '선수 목록',
  })
  items: PlayerSummaryResponseDto[];

  @ApiProperty({
    type: PaginationMetaDto,
    description: '페이지네이션 메타 정보',
  })
  meta: PaginationMetaDto;
}
