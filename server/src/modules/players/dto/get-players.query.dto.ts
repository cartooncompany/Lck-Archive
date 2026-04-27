import { PlayerPosition } from '@prisma/client';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PageQueryDto } from '../../../common/dto/page-query.dto';

export class GetPlayersQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    description: '특정 팀 소속 선수만 조회할 때 사용하는 팀 id',
    example: 'clx123team',
  })
  @IsOptional()
  @IsString()
  teamId?: string;

  @ApiPropertyOptional({
    enum: PlayerPosition,
    description: '포지션 필터',
  })
  @IsOptional()
  @IsEnum(PlayerPosition)
  position?: PlayerPosition;

  @ApiPropertyOptional({
    description: '선수 이름 검색',
    example: 'Faker',
  })
  @IsOptional()
  @IsString()
  keyword?: string;
}
