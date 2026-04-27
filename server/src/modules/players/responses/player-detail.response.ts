import { ApiPropertyOptional } from '@nestjs/swagger';
import { PlayerSummaryResponseDto } from './player-summary.response';

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
}
