import { Injectable } from '@nestjs/common';
import { MatchStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import {
  GetMatchesQueryDto,
  MatchSortOrder,
} from './dto/get-matches.query.dto';
import {
  MatchDetailRecord,
  MatchSummaryRecord,
  matchDetailInclude,
  matchSummaryInclude,
} from './matches.mapper';

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
  ): Promise<MatchSummaryRecord[]> {
    return this.prisma.match.findMany({
      where: {
        status: MatchStatus.COMPLETED,
        OR: [{ homeTeamId: teamId }, { awayTeamId: teamId }],
      },
      include: matchSummaryInclude,
      orderBy: { scheduledAt: 'desc' },
      take: limit,
    });
  }

  async findRecentResults(limit: number): Promise<MatchSummaryRecord[]> {
    return this.prisma.match.findMany({
      where: {
        status: MatchStatus.COMPLETED,
      },
      include: matchSummaryInclude,
      orderBy: { scheduledAt: 'desc' },
      take: limit,
    });
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
