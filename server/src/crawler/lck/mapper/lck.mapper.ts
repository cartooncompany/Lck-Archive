import { Injectable } from '@nestjs/common';
import { MatchStatus, PlayerPosition, Prisma } from '@prisma/client';
import {
  RawLckMatchPayload,
  RawLckPlayerPayload,
  RawLckTeamPayload,
} from '../types/lck-source.types';

const EXTERNAL_SOURCE = 'LCK';

@Injectable()
export class LckMapper {
  toTeamUpsertArgs(team: RawLckTeamPayload): Prisma.TeamUpsertArgs {
    const data = {
      name: team.name,
      shortName: team.shortName,
      slug: this.toSlug(team.shortName),
      logoUrl: team.logoUrl ?? null,
      rank: team.rank ?? null,
      wins: team.wins ?? 0,
      losses: team.losses ?? 0,
      setWins: team.setWins ?? 0,
      setLosses: team.setLosses ?? 0,
      setDifferential: (team.setWins ?? 0) - (team.setLosses ?? 0),
      externalSource: EXTERNAL_SOURCE,
      externalId: team.externalId,
    };

    return {
      where: {
        externalSource_externalId: {
          externalSource: EXTERNAL_SOURCE,
          externalId: team.externalId,
        },
      },
      create: data,
      update: data,
    };
  }

  toPlayerUpsertArgs(
    player: RawLckPlayerPayload,
    teamId?: string,
  ): Prisma.PlayerUpsertArgs {
    const data = {
      teamId: teamId ?? null,
      name: player.name,
      slug: this.toSlug(`${player.name}-${player.externalId}`),
      position: player.position ?? PlayerPosition.FLEX,
      profileImageUrl: player.profileImageUrl ?? null,
      realName: player.realName ?? null,
      nationality: player.nationality ?? null,
      birthDate: player.birthDate ? new Date(player.birthDate) : null,
      recentMatchCount: player.recentMatchCount ?? 0,
      externalSource: EXTERNAL_SOURCE,
      externalId: player.externalId,
    };

    return {
      where: {
        externalSource_externalId: {
          externalSource: EXTERNAL_SOURCE,
          externalId: player.externalId,
        },
      },
      create: data,
      update: data,
    };
  }

  toMatchUpsertArgs(
    match: RawLckMatchPayload,
    homeTeamId: string,
    awayTeamId: string,
    winnerTeamId?: string,
  ): Prisma.MatchUpsertArgs {
    const data = {
      scheduledAt: new Date(match.scheduledAt),
      seasonYear: match.seasonYear,
      split: match.split,
      stage: match.stage,
      matchNumber: match.matchNumber ?? null,
      homeTeamId,
      awayTeamId,
      homeScore: match.homeScore ?? 0,
      awayScore: match.awayScore ?? 0,
      winnerTeamId: winnerTeamId ?? null,
      status: match.status ?? MatchStatus.SCHEDULED,
      vodUrl: match.vodUrl ?? null,
      externalSource: EXTERNAL_SOURCE,
      externalId: match.externalId,
    };

    return {
      where: {
        externalSource_externalId: {
          externalSource: EXTERNAL_SOURCE,
          externalId: match.externalId,
        },
      },
      create: data,
      update: data,
    };
  }

  private toSlug(value: string): string {
    return value
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');
  }
}
