import { ApiProperty } from '@nestjs/swagger';

export class TeamReferenceResponseDto {
  @ApiProperty({ example: 'clx123team' })
  id: string;

  @ApiProperty({ example: 'T1' })
  shortName: string;

  @ApiProperty({ example: 'T1' })
  name: string;

  @ApiProperty({
    example: 'https://cdn.example.com/teams/t1.png',
    nullable: true,
  })
  logoUrl: string | null;
}
