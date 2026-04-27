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
import { GetPlayersQueryDto } from './dto/get-players.query.dto';
import { PlayerDetailResponseDto } from './responses/player-detail.response';
import { PlayerListResponseDto } from './responses/player-summary.response';
import { PlayersService } from './players.service';

@ApiTags('Players')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('players')
export class PlayersController {
  constructor(private readonly playersService: PlayersService) {}

  @Get()
  @ApiOperation({
    summary: '선수 목록 조회',
    description:
      '소속 팀, 포지션, 선수 이름 키워드로 필터링한 선수 목록을 페이지네이션하여 반환합니다.',
  })
  @ApiOkResponse({
    type: PlayerListResponseDto,
    description: '조건에 맞는 선수 목록',
  })
  @ApiBadRequestResponse({
    description: '쿼리 파라미터 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  getPlayers(
    @Query() query: GetPlayersQueryDto,
  ): Promise<PlayerListResponseDto> {
    return this.playersService.getPlayers(query);
  }

  @Get(':id')
  @ApiOperation({
    summary: '선수 상세 조회',
    description: '선수 기본 정보와 상세 프로필 정보를 조회합니다.',
  })
  @ApiParam({
    name: 'id',
    description: '조회할 선수 id',
    example: 'clx123player',
  })
  @ApiOkResponse({
    type: PlayerDetailResponseDto,
    description: '선수 상세 정보',
  })
  @ApiNotFoundResponse({
    description: '해당 id의 선수를 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  getPlayerById(@Param('id') id: string): Promise<PlayerDetailResponseDto> {
    return this.playersService.getPlayerById(id);
  }
}
