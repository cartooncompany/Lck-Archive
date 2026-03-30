import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';
import { PageQueryDto } from '../../../common/dto/page-query.dto';

export class GetTeamsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    description: '팀 이름 또는 약칭 검색',
    example: 'T1',
  })
  @IsOptional()
  @IsString()
  keyword?: string;
}
