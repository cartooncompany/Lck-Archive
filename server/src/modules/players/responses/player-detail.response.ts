import { ApiPropertyOptional } from '@nestjs/swagger';
import { PlayerSummaryResponseDto } from './player-summary.response';

export class PlayerDetailResponseDto extends PlayerSummaryResponseDto {
  @ApiPropertyOptional({ example: 'Lee Sang-hyeok', nullable: true })
  realName: string | null;

  @ApiPropertyOptional({ example: 'KR', nullable: true })
  nationality: string | null;

  @ApiPropertyOptional({
    example: '1996-05-07T00:00:00.000Z',
    format: 'date-time',
    nullable: true,
  })
  birthDate: Date | null;
}
