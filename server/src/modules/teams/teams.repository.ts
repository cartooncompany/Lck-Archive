import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { GetTeamsQueryDto } from './dto/get-teams.query.dto';
import { TeamEntity } from './entities/team.entity';

const teamSelect = Prisma.validator<Prisma.TeamSelect>()({
  id: true,
  name: true,
  shortName: true,
  slug: true,
  logoUrl: true,
  rank: true,
  wins: true,
  losses: true,
  setWins: true,
  setLosses: true,
  setDifferential: true,
  externalSource: true,
  externalId: true,
  createdAt: true,
  updatedAt: true,
});

@Injectable()
export class TeamsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(query: GetTeamsQueryDto): Promise<TeamEntity[]> {
    const teams = await this.prisma.team.findMany({
      where: this.buildWhere(query),
      select: teamSelect,
      orderBy: [{ rank: 'asc' }, { wins: 'desc' }, { name: 'asc' }],
      skip: query.skip,
      take: query.limit,
    });

    return teams as TeamEntity[];
  }

  async count(query: GetTeamsQueryDto): Promise<number> {
    return this.prisma.team.count({
      where: this.buildWhere(query),
    });
  }

  async findById(id: string): Promise<TeamEntity | null> {
    const team = await this.prisma.team.findUnique({
      where: { id },
      select: teamSelect,
    });

    return team as TeamEntity | null;
  }

  private buildWhere(query: GetTeamsQueryDto): Prisma.TeamWhereInput {
    if (!query.keyword) {
      return {};
    }

    return {
      OR: [
        {
          name: {
            contains: query.keyword,
            mode: 'insensitive',
          },
        },
        {
          shortName: {
            contains: query.keyword,
            mode: 'insensitive',
          },
        },
      ],
    };
  }
}
