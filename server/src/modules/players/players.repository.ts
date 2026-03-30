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
