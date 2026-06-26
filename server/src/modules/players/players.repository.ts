import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { GetPlayersQueryDto } from './dto/get-players.query.dto';

const teamReferenceSelect = Prisma.validator<Prisma.TeamSelect>()({
  id: true,
  name: true,
  shortName: true,
  logoUrl: true,
});

const playerInclude = Prisma.validator<Prisma.PlayerInclude>()({
  team: {
    select: teamReferenceSelect,
  },
});

export type PlayerRecord = Prisma.PlayerGetPayload<{
  include: typeof playerInclude;
}>;

@Injectable()
export class PlayersRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(query: GetPlayersQueryDto): Promise<PlayerRecord[]> {
    return this.prisma.player.findMany({
      where: this.buildWhere(query),
      include: playerInclude,
      orderBy: [{ teamId: 'asc' }, { name: 'asc' }],
      skip: query.skip,
      take: query.limit,
    });
  }

  async count(query: GetPlayersQueryDto): Promise<number> {
    return this.prisma.player.count({
      where: this.buildWhere(query),
    });
  }

  async findById(id: string): Promise<PlayerRecord | null> {
    return this.prisma.player.findUnique({
      where: { id },
      include: playerInclude,
    });
  }

  async getPlayerStats(playerId: string) {
    const stats = await this.prisma.matchGamePlayerStat.aggregate({
      where: {
        playerId,
      },
      _sum: {
        kills: true,
        deaths: true,
        assists: true,
      },
      _avg: {
        kills: true,
        deaths: true,
        assists: true,
      },
      _count: {
        id: true,
      },
    });

    const gamesPlayed = stats._count.id;
    const totalKills = stats._sum.kills ?? 0;
    const totalDeaths = stats._sum.deaths ?? 0;
    const totalAssists = stats._sum.assists ?? 0;

    const avgKills = stats._avg.kills ? Number(stats._avg.kills.toFixed(2)) : 0;
    const avgDeaths = stats._avg.deaths
      ? Number(stats._avg.deaths.toFixed(2))
      : 0;
    const avgAssists = stats._avg.assists
      ? Number(stats._avg.assists.toFixed(2))
      : 0;

    const avgKda =
      totalDeaths > 0
        ? Number(((totalKills + totalAssists) / totalDeaths).toFixed(2))
        : Number((totalKills + totalAssists).toFixed(2));

    return {
      gamesPlayed,
      totalKills,
      totalDeaths,
      totalAssists,
      avgKills,
      avgDeaths,
      avgAssists,
      avgKda,
    };
  }

  async getRecentAppearances(playerId: string, limit = 5) {
    const statsList = await this.prisma.matchGamePlayerStat.findMany({
      where: { playerId },
      select: {
        kills: true,
        deaths: true,
        assists: true,
        characterName: true,
        team: {
          select: {
            id: true,
          },
        },
        matchGame: {
          select: {
            winnerTeamId: true,
            match: {
              select: {
                scheduledAt: true,
                homeTeamId: true,
                homeTeam: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
                awayTeam: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: {
        matchGame: {
          match: {
            scheduledAt: 'desc',
          },
        },
      },
      take: limit,
    });

    return statsList.map((stat) => {
      const match = stat.matchGame.match;
      const myTeam = stat.team;
      const isHome = match.homeTeamId === myTeam.id;
      const opponent = isHome ? match.awayTeam : match.homeTeam;
      
      const isWin = stat.matchGame.winnerTeamId === myTeam.id;
      
      const kills = stat.kills ?? 0;
      const deaths = stat.deaths ?? 0;
      const assists = stat.assists ?? 0;
      const champ = stat.characterName ?? '미상';
      const performance = `${kills} / ${deaths} / ${assists} (${champ})`;

      return {
        playedAt: match.scheduledAt,
        opponent: opponent.name,
        result: isWin ? '승' : '패',
        performance,
      };
    });
  }

  private buildWhere(query: GetPlayersQueryDto): Prisma.PlayerWhereInput {
    return {
      teamId: query.teamId,
      position: query.position,
      ...(query.keyword
        ? {
            name: {
              contains: query.keyword,
              mode: 'insensitive',
            },
          }
        : {}),
    };
  }
}
