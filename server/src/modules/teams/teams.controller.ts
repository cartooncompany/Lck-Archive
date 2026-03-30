import { Controller, Get, Param, Query } from '@nestjs/common';
import {
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { GetMatchesQueryDto } from '../matches/dto/get-matches.query.dto';
import { MatchListResponseDto } from '../matches/responses/match-summary.response';
import { GetTeamsQueryDto } from './dto/get-teams.query.dto';
import { TeamDetailResponseDto } from './responses/team-detail.response';
import { TeamListResponseDto } from './responses/team-summary.response';
import { TeamsService } from './teams.service';

@ApiTags('Teams')
@Controller('teams')
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Get()
  @ApiOperation({ summary: '팀 목록 조회' })
  @ApiOkResponse({ type: TeamListResponseDto })
  getTeams(@Query() query: GetTeamsQueryDto): Promise<TeamListResponseDto> {
    return this.teamsService.getTeams(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '팀 상세 조회' })
  @ApiParam({ name: 'id', description: '팀 id' })
  @ApiOkResponse({ type: TeamDetailResponseDto })
  @ApiNotFoundResponse({ description: '팀을 찾을 수 없습니다.' })
  getTeamById(@Param('id') id: string): Promise<TeamDetailResponseDto> {
    return this.teamsService.getTeamById(id);
  }

  @Get(':id/matches')
  @ApiOperation({ summary: '특정 팀의 경기 목록 조회' })
  @ApiParam({ name: 'id', description: '팀 id' })
  @ApiOkResponse({ type: MatchListResponseDto })
  @ApiNotFoundResponse({ description: '팀을 찾을 수 없습니다.' })
  getTeamMatches(
    @Param('id') id: string,
    @Query() query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
    return this.teamsService.getTeamMatches(id, query);
  }
}
