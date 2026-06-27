import { Injectable, NotFoundException } from '@nestjs/common';
import { CacheInvalidatorService } from '../../common/cache/cache-invalidator.service';
import { CacheNamespace } from '../../common/cache/cache-namespaces';
import { buildCacheKey } from '../../common/utils/cache-key.util';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { MatchesRepository } from '../matches/matches.repository';
import { MatchMapper, MatchSummaryRecord } from '../matches/matches.mapper';
import { GetMatchesQueryDto } from '../matches/dto/get-matches.query.dto';
import { MatchListResponseDto } from '../matches/responses/match-summary.response';
import { GetTeamsQueryDto } from './dto/get-teams.query.dto';
import { TeamEntity } from './entities/team.entity';
import {
  RecentFormResult,
  TeamDetailResponseDto,
} from './responses/team-detail.response';
import {
  TeamListResponseDto,
  TeamSummaryResponseDto,
} from './responses/team-summary.response';
import { TeamsRepository } from './teams.repository';

@Injectable()
export class TeamsService {
  constructor(
    private readonly teamsRepository: TeamsRepository,
    private readonly matchesRepository: MatchesRepository,
    private readonly matchMapper: MatchMapper,
    private readonly cache: CacheInvalidatorService,
  ) {}

  async getTeams(query: GetTeamsQueryDto): Promise<TeamListResponseDto> {
    const cacheKey = buildCacheKey(CacheNamespace.TEAMS, 'list', query);
    const cached = await this.cache.get<TeamListResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const [teams, total] = await Promise.all([
      this.teamsRepository.findMany(query),
      this.teamsRepository.count(query),
    ]);

    const result = {
      items: teams.map((team) => this.toTeamSummary(team)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cache.set(
      CacheNamespace.TEAMS,
      cacheKey,
      result,
      10 * 60 * 1000,
    ); // 10분 캐싱 (팀 순위 등은 거의 고정됨)
    return result;
  }

  async getTeamById(id: string): Promise<TeamDetailResponseDto> {
    const cacheKey = buildCacheKey(CacheNamespace.TEAMS, 'detail', id);
    const cached = await this.cache.get<TeamDetailResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const [team, recentMatches] = await Promise.all([
      this.teamsRepository.findById(id),
      this.matchesRepository.findRecentByTeam(id, 5),
    ]);

    if (!team) {
      throw new NotFoundException(`Team not found: ${id}`);
    }

    const result = {
      ...this.toTeamSummary(team),
      recentForm: recentMatches.map((match) =>
        this.getRecentFormResult(match, id),
      ),
    };

    await this.cache.set(
      CacheNamespace.TEAMS,
      cacheKey,
      result,
      15 * 60 * 1000,
    ); // 15분 캐싱
    return result;
  }

  async getTeamMatches(
    id: string,
    query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
    const cacheKey = buildCacheKey(
      CacheNamespace.TEAMS,
      `matches:${id}`,
      query,
    );
    const cached = await this.cache.get<MatchListResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const team = await this.teamsRepository.findById(id);

    if (!team) {
      throw new NotFoundException(`Team not found: ${id}`);
    }

    const matchQuery = Object.assign(new GetMatchesQueryDto(), query, {
      teamId: id,
    });

    const [matches, total] = await Promise.all([
      this.matchesRepository.findMany(matchQuery),
      this.matchesRepository.count(matchQuery),
    ]);

    const result = {
      items: matches.map((match) => this.matchMapper.toSummaryDto(match)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cache.set(CacheNamespace.TEAMS, cacheKey, result, 5 * 60 * 1000); // 5분 캐싱
    return result;
  }

  private toTeamSummary(team: TeamEntity): TeamSummaryResponseDto {
    return {
      id: team.id,
      name: team.name,
      shortName: team.shortName,
      logoUrl: team.logoUrl,
      rank: team.rank,
      wins: team.wins,
      losses: team.losses,
      setWins: team.setWins,
      setLosses: team.setLosses,
      setDifferential: team.setDifferential,
    };
  }

  private getRecentFormResult(
    match: MatchSummaryRecord,
    teamId: string,
  ): RecentFormResult {
    return match.winnerTeamId === teamId
      ? RecentFormResult.WIN
      : RecentFormResult.LOSS;
  }
}
