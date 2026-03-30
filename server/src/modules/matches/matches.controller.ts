import { Controller, Get, Param, Query } from '@nestjs/common';
import {
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { MatchDetailResponseDto } from './responses/match-detail.response';
import { MatchListResponseDto } from './responses/match-summary.response';
import { MatchesService } from './matches.service';

@ApiTags('Matches')
@Controller('matches')
export class MatchesController {
  constructor(private readonly matchesService: MatchesService) {}

  @Get()
  @ApiOperation({ summary: '경기 목록 조회' })
  @ApiOkResponse({ type: MatchListResponseDto })
  getMatches(
    @Query() query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
    return this.matchesService.getMatches(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '경기 상세 조회' })
  @ApiParam({ name: 'id', description: '경기 id' })
  @ApiOkResponse({ type: MatchDetailResponseDto })
  @ApiNotFoundResponse({ description: '경기를 찾을 수 없습니다.' })
  getMatchById(@Param('id') id: string): Promise<MatchDetailResponseDto> {
    return this.matchesService.getMatchById(id);
  }
}
