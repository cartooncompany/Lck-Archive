import { Injectable, Logger, NotFoundException, Inject } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import * as cacheManager from 'cache-manager';
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
  private readonly logger = new Logger(PlayersService.name);

  constructor(
    private readonly playersRepository: PlayersRepository,
    @Inject(CACHE_MANAGER) private readonly cacheManager: cacheManager.Cache,
  ) {}

  async getPlayers(query: GetPlayersQueryDto): Promise<PlayerListResponseDto> {
    const cacheKey = `players:list:${JSON.stringify(query)}`;
    const cached = await this.cacheManager.get<PlayerListResponseDto>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for players list: ${cacheKey}`);
      return cached;
    }

    const [players, total] = await Promise.all([
      this.playersRepository.findMany(query),
      this.playersRepository.count(query),
    ]);

    const result = {
      items: players.map((player) => this.toPlayerSummary(player)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cacheManager.set(cacheKey, result, 5 * 60 * 1000); // 5분 캐싱
    return result;
  }

  async getPlayerById(id: string): Promise<PlayerDetailResponseDto> {
    const cacheKey = `player:detail:${id}`;
    const cached = await this.cacheManager.get<PlayerDetailResponseDto>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for player detail: ${cacheKey}`);
      return cached;
    }

    const [player, stats, recentAppearances] = await Promise.all([
      this.playersRepository.findById(id),
      this.playersRepository.getPlayerStats(id),
      this.playersRepository.getRecentAppearances(id),
    ]);

    if (!player) {
      throw new NotFoundException(`Player not found: ${id}`);
    }

    const result = {
      ...this.toPlayerSummary(player),
      realName: player.realName,
      nationality: player.nationality,
      birthDate: player.birthDate,
      stats,
      recentAppearances,
      aiSummary: player.aiSummary,
    };

    await this.cacheManager.set(cacheKey, result, 10 * 60 * 1000); // 10분 캐싱
    return result;
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
