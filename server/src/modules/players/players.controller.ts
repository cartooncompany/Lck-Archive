import { Controller, Get, Param, Query } from '@nestjs/common';
import {
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { GetPlayersQueryDto } from './dto/get-players.query.dto';
import { PlayerDetailResponseDto } from './responses/player-detail.response';
import { PlayerListResponseDto } from './responses/player-summary.response';
import { PlayersService } from './players.service';

@ApiTags('Players')
@Controller('players')
export class PlayersController {
  constructor(private readonly playersService: PlayersService) {}

  @Get()
  @ApiOperation({ summary: '선수 목록 조회' })
  @ApiOkResponse({ type: PlayerListResponseDto })
  getPlayers(
    @Query() query: GetPlayersQueryDto,
  ): Promise<PlayerListResponseDto> {
    return this.playersService.getPlayers(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '선수 상세 조회' })
  @ApiParam({ name: 'id', description: '선수 id' })
  @ApiOkResponse({ type: PlayerDetailResponseDto })
  @ApiNotFoundResponse({ description: '선수를 찾을 수 없습니다.' })
  getPlayerById(@Param('id') id: string): Promise<PlayerDetailResponseDto> {
    return this.playersService.getPlayerById(id);
  }
}
