import { Controller, Get, Param, Query } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import {
  ErrorResponseDto,
  ServiceUnavailableErrorResponseDto,
  ValidationErrorResponseDto,
} from '../../common/responses/error-response.dto';
import { GetMatchesQueryDto } from '../matches/dto/get-matches.query.dto';
import { MatchListResponseDto } from '../matches/responses/match-summary.response';
import { GetTeamsQueryDto } from './dto/get-teams.query.dto';
import { TeamDetailResponseDto } from './responses/team-detail.response';
import { TeamListResponseDto } from './responses/team-summary.response';
import { TeamsService } from './teams.service';

@ApiTags('Teams')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('teams')
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Get()
  @ApiOperation({
    summary: '팀 목록 조회',
    description:
      '팀명 또는 약칭 키워드로 필터링한 LCK 팀 목록과 순위/전적 정보를 페이지네이션하여 조회합니다.',
  })
  @ApiOkResponse({
    type: TeamListResponseDto,
    description: '조건에 맞는 팀 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  getTeams(@Query() query: GetTeamsQueryDto): Promise<TeamListResponseDto> {
    return this.teamsService.getTeams(query);
  }

  @Get(':id')
  @ApiOperation({
    summary: '팀 상세 조회',
    description:
      '팀 기본 정보와 최근 5경기 기준의 최근 폼(recentForm) 정보를 함께 조회합니다.',
  })
  @ApiParam({
    name: 'id',
    description: '조회할 팀 id',
    example: 'clx123team',
  })
  @ApiOkResponse({
    type: TeamDetailResponseDto,
    description: '팀 상세 정보',
  })
  @ApiNotFoundResponse({
    description: '해당 id의 팀을 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  getTeamById(@Param('id') id: string): Promise<TeamDetailResponseDto> {
    return this.teamsService.getTeamById(id);
  }

  @Get(':id/matches')
  @ApiOperation({
    summary: '팀별 경기 목록 조회',
    description:
      'path의 팀 id를 기준으로 해당 팀이 참여한 경기만 조회합니다. `teamId` 쿼리 파라미터가 전달되더라도 path 값이 우선 적용됩니다.',
  })
  @ApiParam({
    name: 'id',
    description: '경기 목록을 조회할 팀 id',
    example: 'clx123team',
  })
  @ApiOkResponse({
    type: MatchListResponseDto,
    description: '해당 팀이 참여한 경기 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  @ApiNotFoundResponse({
    description: '해당 id의 팀을 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  getTeamMatches(
    @Param('id') id: string,
    @Query() query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
    return this.teamsService.getTeamMatches(id, query);
  }
}
