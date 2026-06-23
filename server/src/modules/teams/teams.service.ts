import { Injectable, NotFoundException } from '@nestjs/common';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { MatchesRepository } from '../matches/matches.repository';
import { GetMatchesQueryDto } from '../matches/dto/get-matches.query.dto';
import {
  MatchListResponseDto,
  MatchSummaryResponseDto,
} from '../matches/responses/match-summary.response';
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
  ) {}

  async getTeams(query: GetTeamsQueryDto): Promise<TeamListResponseDto> {
    const [teams, total] = await Promise.all([
      this.teamsRepository.findMany(query),
      this.teamsRepository.count(query),
    ]);

    return {
      items: teams.map((team) => this.toTeamSummary(team)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };
  }

  async getTeamById(id: string): Promise<TeamDetailResponseDto> {
    const [team, recentMatches] = await Promise.all([
      this.teamsRepository.findById(id),
      this.matchesRepository.findRecentByTeam(id, 5),
    ]);

    if (!team) {
      throw new NotFoundException(`Team not found: ${id}`);
    }

    return {
      ...this.toTeamSummary(team),
      recentForm: recentMatches.map((match) =>
        this.getRecentFormResult(match, id),
      ),
    };
  }

  async getTeamMatches(
    id: string,
    query: GetMatchesQueryDto,
  ): Promise<MatchListResponseDto> {
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

    return {
      items: matches.map((match) => this.matchesRepository.toSummaryDto(match)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };
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
    match: MatchSummaryResponseDto,
    teamId: string,
  ): RecentFormResult {
    return match.winner?.id === teamId
      ? RecentFormResult.WIN
      : RecentFormResult.LOSS;
  }
}
