import { Injectable, NotFoundException } from '@nestjs/common';
import { TeamReferenceResponseDto } from '../../common/responses/team-reference.response';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetPlayersQueryDto } from './dto/get-players.query.dto';
import { PlayerDetailResponseDto } from './responses/player-detail.response';
import {
  PlayerListResponseDto,
  PlayerSummaryResponseDto,
} from './responses/player-summary.response';
import { PlayerRecord, PlayersRepository } from './players.repository';

@Injectable()
export class PlayersService {
  constructor(private readonly playersRepository: PlayersRepository) {}

  async getPlayers(query: GetPlayersQueryDto): Promise<PlayerListResponseDto> {
    const [players, total] = await Promise.all([
      this.playersRepository.findMany(query),
      this.playersRepository.count(query),
    ]);

    return {
      items: players.map((player) => this.toPlayerSummary(player)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };
  }

  async getPlayerById(id: string): Promise<PlayerDetailResponseDto> {
    const player = await this.playersRepository.findById(id);

    if (!player) {
      throw new NotFoundException(`Player not found: ${id}`);
    }

    return {
      ...this.toPlayerSummary(player),
      realName: player.realName,
      nationality: player.nationality,
      birthDate: player.birthDate,
    };
  }

  private toPlayerSummary(player: PlayerRecord): PlayerSummaryResponseDto {
    return {
      id: player.id,
      name: player.name,
      position: player.position,
      profileImageUrl: player.profileImageUrl,
      recentMatchCount: player.recentMatchCount,
      team: player.team ? this.toTeamReference(player.team) : null,
    };
  }

  private toTeamReference(team: {
    id: string;
    name: string;
    shortName: string;
    logoUrl: string | null;
  }): TeamReferenceResponseDto {
    return {
      id: team.id,
      name: team.name,
      shortName: team.shortName,
      logoUrl: team.logoUrl,
    };
  }
}
