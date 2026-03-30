import { Injectable } from '@nestjs/common';
import { MatchStatus, Prisma } from '@prisma/client';
import { TeamReferenceResponseDto } from '../../common/responses/team-reference.response';
import { PrismaService } from '../../database/prisma.service';
import {
  GetMatchesQueryDto,
  MatchSortOrder,
} from './dto/get-matches.query.dto';
import {
  MatchDetailResponseDto,
  MatchParticipantResponseDto,
} from './responses/match-detail.response';
import { MatchSummaryResponseDto } from './responses/match-summary.response';

const teamReferenceSelect = Prisma.validator<Prisma.TeamSelect>()({
  id: true,
  name: true,
  shortName: true,
  logoUrl: true,
});

const matchSummaryInclude = Prisma.validator<Prisma.MatchInclude>()({
  homeTeam: {
    select: teamReferenceSelect,
  },
  awayTeam: {
    select: teamReferenceSelect,
  },
  winnerTeam: {
    select: teamReferenceSelect,
  },
});

const matchDetailInclude = Prisma.validator<Prisma.MatchInclude>()({
  homeTeam: {
    select: teamReferenceSelect,
  },
  awayTeam: {
    select: teamReferenceSelect,
  },
  winnerTeam: {
    select: teamReferenceSelect,
  },
  participations: {
    include: {
      player: true,
      team: {
        select: teamReferenceSelect,
      },
    },
    orderBy: [{ teamId: 'asc' }, { createdAt: 'asc' }],
  },
});

export type MatchSummaryRecord = Prisma.MatchGetPayload<{
  include: typeof matchSummaryInclude;
}>;

type MatchDetailRecord = Prisma.MatchGetPayload<{
  include: typeof matchDetailInclude;
}>;

@Injectable()
export class MatchesRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(query: GetMatchesQueryDto): Promise<MatchSummaryRecord[]> {
    return this.prisma.match.findMany({
      where: this.buildWhere(query),
      include: matchSummaryInclude,
      orderBy: { scheduledAt: this.resolveSortOrder(query) },
      skip: query.skip,
      take: query.limit,
    });
  }

  async count(query: GetMatchesQueryDto): Promise<number> {
    return this.prisma.match.count({
      where: this.buildWhere(query),
    });
  }

  async findById(id: string): Promise<MatchDetailRecord | null> {
    return this.prisma.match.findUnique({
      where: { id },
      include: matchDetailInclude,
    });
  }

  async findRecentByTeam(
    teamId: string,
    limit: number,
  ): Promise<MatchSummaryResponseDto[]> {
    const matches = await this.prisma.match.findMany({
      where: {
        status: MatchStatus.COMPLETED,
        OR: [{ homeTeamId: teamId }, { awayTeamId: teamId }],
      },
      include: matchSummaryInclude,
      orderBy: { scheduledAt: 'desc' },
      take: limit,
    });

    return matches.map((match) => this.toSummaryDto(match));
  }

  toSummaryDto(match: MatchSummaryRecord): MatchSummaryResponseDto {
    return {
      id: match.id,
      scheduledAt: match.scheduledAt,
      seasonYear: match.seasonYear,
      split: match.split,
      stage: match.stage,
      status: match.status,
      homeTeam: this.toTeamReference(match.homeTeam),
      awayTeam: this.toTeamReference(match.awayTeam),
      score: {
        home: match.homeScore,
        away: match.awayScore,
      },
      winner: match.winnerTeam ? this.toTeamReference(match.winnerTeam) : null,
    };
  }

  toDetailDto(match: MatchDetailRecord): MatchDetailResponseDto {
    return {
      ...this.toSummaryDto(match),
      matchNumber: match.matchNumber,
      vodUrl: match.vodUrl,
      participants: match.participations.map((participation) =>
        this.toParticipantDto(participation),
      ),
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

  private toParticipantDto(participation: {
    player: {
      id: string;
      name: string;
      position: MatchParticipantResponseDto['position'];
    };
    team: {
      id: string;
      name: string;
      shortName: string;
      logoUrl: string | null;
    };
    role: MatchParticipantResponseDto['position'] | null;
    isStarter: boolean;
  }): MatchParticipantResponseDto {
    return {
      playerId: participation.player.id,
      playerName: participation.player.name,
      position: participation.role ?? participation.player.position,
      isStarter: participation.isStarter,
      team: this.toTeamReference(participation.team),
    };
  }

  private buildWhere(query: GetMatchesQueryDto): Prisma.MatchWhereInput {
    return {
      ...(query.teamId
        ? {
            OR: [{ homeTeamId: query.teamId }, { awayTeamId: query.teamId }],
          }
        : {}),
      ...(query.seasonYear ? { seasonYear: query.seasonYear } : {}),
      ...(query.split ? { split: query.split } : {}),
      ...(query.stage ? { stage: query.stage } : {}),
      ...(query.status ? { status: query.status } : {}),
      ...(query.from || query.to
        ? {
            scheduledAt: {
              ...(query.from ? { gte: query.from } : {}),
              ...(query.to ? { lte: query.to } : {}),
            },
          }
        : {}),
    };
  }

  private resolveSortOrder(query: GetMatchesQueryDto): Prisma.SortOrder {
    return query.sortOrder === MatchSortOrder.ASC ? 'asc' : 'desc';
  }
}
