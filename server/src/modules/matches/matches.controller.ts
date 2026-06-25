import { Controller, Get, Param, Post, Query } from '@nestjs/common';
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
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { GetRecentMatchesQueryDto } from './dto/get-recent-matches.query.dto';
import { MatchDetailResponseDto } from './responses/match-detail.response';
import {
  MatchListResponseDto,
  MatchSummaryResponseDto,
} from './responses/match-summary.response';
import { MatchesService } from './matches.service';

@ApiTags('Matches')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('matches')
export class MatchesController {
  constructor(private readonly matchesService: MatchesService) {}

  @Get()
  @ApiOperation({
    summary: '경기 목록 조회',
    description:
      '팀, 시즌, split, stage, 경기 상태, 경기 시각 범위 조건으로 경기 목록을 페이지네이션하여 조회합니다.',
  })
  @ApiOkResponse({
    type: MatchListResponseDto,
    description: '조건에 맞는 경기 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  getMatches(
    @Query() query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
    return this.matchesService.getMatches(query);
  }

  @Get('recent-results')
  @ApiOperation({
    summary: '최근 경기 결과 조회',
    description: '최근에 완료된(COMPLETED) 경기 결과 목록을 조회합니다.',
  })
  @ApiOkResponse({
    type: [MatchSummaryResponseDto],
    description: '최근 경기 결과 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  getRecentResults(
    @Query() query: GetRecentMatchesQueryDto,
  ): Promise<MatchSummaryResponseDto[]> {
    return this.matchesService.getRecentResults(query);
  }

  @Get(':id')
  @ApiOperation({
    summary: '경기 상세 조회',
    description:
      '경기 기본 정보에 더해 출전 선수(participants), 경기 번호, VOD URL을 포함한 상세 정보를 조회합니다.',
  })
  @ApiParam({
    name: 'id',
    description: '조회할 경기 id',
    example: 'clx123match',
  })
  @ApiOkResponse({
    type: MatchDetailResponseDto,
    description: '경기 상세 정보',
  })
  @ApiNotFoundResponse({
    description: '해당 id의 경기를 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  getMatchById(@Param('id') id: string): Promise<MatchDetailResponseDto> {
    return this.matchesService.getMatchById(id);
  }
}
