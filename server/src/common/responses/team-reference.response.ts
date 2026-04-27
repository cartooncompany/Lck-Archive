import { ApiProperty } from '@nestjs/swagger';

export class TeamReferenceResponseDto {
  @ApiProperty({
    example: 'clx123team',
    description: '팀 고유 id',
  })
  id: string;

  @ApiProperty({
    example: 'T1',
    description: '팀 약칭',
  })
  shortName: string;

  @ApiProperty({
    example: 'T1',
    description: '팀 전체 이름',
  })
  name: string;

  @ApiProperty({
    example: 'https://cdn.example.com/teams/t1.png',
    nullable: true,
    description: '팀 로고 이미지 URL',
  })
  logoUrl: string | null;
}
