import { Injectable } from '@nestjs/common';
import { MatchStatus, PlayerPosition } from '@prisma/client';
import {
  RawLckMatchPayload,
  RawLckPlayerPayload,
  RawLckSnapshotPayload,
  RawLckTeamPayload,
} from '../types/lck-source.types';
import {
  GridLckSnapshotPayload,
  GridPlayerNode,
  GridSeriesNode,
  GridSeriesState,
} from '../types/grid-source.types';

interface GridDerivedTeam {
  externalId: string;
  name: string;
  shortName: string;
  logoUrl: string | null;
}

interface GridTeamRecord {
  wins: number;
  losses: number;
  setWins: number;
  setLosses: number;
}

@Injectable()
export class GridLckParser {
  parseSnapshot(payload: GridLckSnapshotPayload): RawLckSnapshotPayload {
    const teamsById = this.collectTeams(payload.series);
    const matches = this.parseMatches(payload.series, payload.statesBySeriesId);
    const teamRecords = this.buildTeamRecords(matches);
    const teams = this.rankTeams(teamsById, teamRecords);
    const players = this.parsePlayers(payload.playersByTeamId);

    return {
      teams,
      players,
      matches,
    };
  }

  private collectTeams(series: GridSeriesNode[]): Map<string, GridDerivedTeam> {
    const teamsById = new Map<string, GridDerivedTeam>();

    for (const entry of series) {
      for (const competitor of entry.teams ?? []) {
        const team = competitor.baseInfo;

        if (!team || this.isPlaceholderTeam(team.name)) {
          continue;
        }

        const current = teamsById.get(team.id);

        teamsById.set(team.id, {
          externalId: team.id,
          name: current?.name ?? team.name,
          shortName: current?.shortName ?? this.toShortName(team.name),
          logoUrl: current?.logoUrl ?? team.logoUrl ?? null,
        });
      }
    }

    return teamsById;
  }

  private parseMatches(
    series: GridSeriesNode[],
    statesBySeriesId: Record<string, GridSeriesState | null>,
  ): RawLckMatchPayload[] {
    const matches: RawLckMatchPayload[] = [];

    for (const entry of series) {
      const competitors = (entry.teams ?? [])
        .map((team) => team.baseInfo)
        .filter((team): team is NonNullable<typeof team> => Boolean(team))
        .filter((team) => !this.isPlaceholderTeam(team.name));

      if (competitors.length < 2) {
        continue;
      }

      const [homeTeam, awayTeam] = competitors;
      const state = statesBySeriesId[entry.id];
      const scoreByTeamId = new Map(
        (state?.teams ?? []).map((team) => [team.id, team.score ?? 0]),
      );
      const winnerTeamId =
        (state?.teams ?? []).find((team) => team.won)?.id ??
        this.resolveWinnerFromScore(
          homeTeam.id,
          awayTeam.id,
          scoreByTeamId.get(homeTeam.id) ?? 0,
          scoreByTeamId.get(awayTeam.id) ?? 0,
          state,
        );

      matches.push({
        externalId: entry.id,
        scheduledAt: entry.startTimeScheduled,
        seasonYear: new Date(entry.startTimeScheduled).getUTCFullYear(),
        split: entry.tournament?.name ?? 'LCK',
        stage: entry.tournament?.name ?? 'LCK',
        matchNumber: null,
        homeTeamExternalId: homeTeam.id,
        awayTeamExternalId: awayTeam.id,
        homeScore: scoreByTeamId.get(homeTeam.id) ?? 0,
        awayScore: scoreByTeamId.get(awayTeam.id) ?? 0,
        winnerTeamExternalId: winnerTeamId,
        status: state?.finished ? MatchStatus.COMPLETED : MatchStatus.SCHEDULED,
        vodUrl: null,
      });
    }

    return matches.sort(
      (left, right) =>
        new Date(left.scheduledAt).getTime() - new Date(right.scheduledAt).getTime(),
    );
  }

  private parsePlayers(
    playersByTeamId: Record<string, GridPlayerNode[]>,
  ): RawLckPlayerPayload[] {
    const players = new Map<string, RawLckPlayerPayload>();

    for (const [teamId, roster] of Object.entries(playersByTeamId)) {
      for (const player of roster) {
        players.set(player.id, {
          externalId: player.id,
          name: player.nickname,
          teamExternalId: teamId,
          position: this.toPlayerPosition(player.roles),
          profileImageUrl: null,
          realName: null,
          nationality: null,
          birthDate: null,
          recentMatchCount: 0,
        });
      }
    }

    return [...players.values()].sort((left, right) =>
      left.name.localeCompare(right.name),
    );
  }

  private buildTeamRecords(
    matches: RawLckMatchPayload[],
  ): Map<string, GridTeamRecord> {
    const records = new Map<string, GridTeamRecord>();

    for (const match of matches) {
      this.accumulateSetRecord(
        records,
        match.homeTeamExternalId,
        match.homeScore ?? 0,
        match.awayScore ?? 0,
      );
      this.accumulateSetRecord(
        records,
        match.awayTeamExternalId,
        match.awayScore ?? 0,
        match.homeScore ?? 0,
      );

      if (match.status !== MatchStatus.COMPLETED || !match.winnerTeamExternalId) {
        continue;
      }

      const loserTeamId =
        match.winnerTeamExternalId === match.homeTeamExternalId
          ? match.awayTeamExternalId
          : match.homeTeamExternalId;

      this.accumulateSeriesOutcome(records, match.winnerTeamExternalId, 'win');
      this.accumulateSeriesOutcome(records, loserTeamId, 'loss');
    }

    return records;
  }

  private rankTeams(
    teamsById: Map<string, GridDerivedTeam>,
    records: Map<string, GridTeamRecord>,
  ): RawLckTeamPayload[] {
    const teams = [...teamsById.values()].map((team) => {
      const record = records.get(team.externalId) ?? {
        wins: 0,
        losses: 0,
        setWins: 0,
        setLosses: 0,
      };

      return {
        externalId: team.externalId,
        name: team.name,
        shortName: team.shortName,
        logoUrl: team.logoUrl,
        rank: null,
        wins: record.wins,
        losses: record.losses,
        setWins: record.setWins,
        setLosses: record.setLosses,
      } satisfies RawLckTeamPayload;
    });

    teams.sort((left, right) => {
      const rightSetDiff = (right.setWins ?? 0) - (right.setLosses ?? 0);
      const leftSetDiff = (left.setWins ?? 0) - (left.setLosses ?? 0);

      return (
        (right.wins ?? 0) - (left.wins ?? 0) ||
        rightSetDiff - leftSetDiff ||
        (right.setWins ?? 0) - (left.setWins ?? 0) ||
        left.name.localeCompare(right.name)
      );
    });

    return teams.map((team, index) => ({
      ...team,
      rank: index + 1,
    }));
  }

  private toShortName(name: string): string {
    const compact = name.replace(/[^A-Za-z0-9]/g, '');

    if (compact.length > 0 && compact.length <= 5) {
      return compact.toUpperCase();
    }

    const initials = name
      .split(/\s+/)
      .map((token) => token.replace(/[^A-Za-z0-9]/g, ''))
      .filter(Boolean)
      .map((token) => token[0]?.toUpperCase() ?? '')
      .join('');

    if (initials.length >= 2 && initials.length <= 5) {
      return initials;
    }

    const uppercaseToken = name
      .split(/\s+/)
      .map((token) => token.replace(/[^A-Za-z0-9]/g, ''))
      .find((token) => /^[A-Z0-9]{2,5}$/.test(token));

    if (uppercaseToken) {
      return uppercaseToken;
    }

    const firstToken = name
      .split(/\s+/)[0]
      ?.replace(/[^A-Za-z0-9]/g, '')
      .toUpperCase();

    return firstToken || name;
  }

  private toPlayerPosition(
    roles?: GridPlayerNode['roles'],
  ): PlayerPosition {
    const candidates = (roles ?? [])
      .flatMap((role) => [role.name, role.title?.name])
      .filter((value): value is string => Boolean(value))
      .map((value) => value.toLowerCase());

    for (const role of candidates) {
      switch (role) {
        case 'top':
        case 'top lane':
          return PlayerPosition.TOP;
        case 'jungle':
        case 'jungler':
          return PlayerPosition.JUNGLE;
        case 'mid':
        case 'middle':
        case 'mid lane':
          return PlayerPosition.MID;
        case 'bottom':
        case 'bottom lane':
        case 'adc':
        case 'bot':
          return PlayerPosition.ADC;
        case 'support':
          return PlayerPosition.SUPPORT;
        case 'coach':
          return PlayerPosition.COACH;
        case 'substitute':
        case 'sub':
          return PlayerPosition.SUBSTITUTE;
        default:
          break;
      }
    }

    return PlayerPosition.FLEX;
  }

  private resolveWinnerFromScore(
    homeTeamId: string,
    awayTeamId: string,
    homeScore: number,
    awayScore: number,
    state?: GridSeriesState | null,
  ): string | null {
    if (!state?.finished) {
      return null;
    }

    if (homeScore === awayScore) {
      return null;
    }

    return homeScore > awayScore ? homeTeamId : awayTeamId;
  }

  private accumulateSeriesOutcome(
    records: Map<string, GridTeamRecord>,
    teamId: string,
    outcome: 'win' | 'loss',
  ): void {
    const current = records.get(teamId) ?? {
      wins: 0,
      losses: 0,
      setWins: 0,
      setLosses: 0,
    };

    records.set(teamId, {
      ...current,
      wins: current.wins + (outcome === 'win' ? 1 : 0),
      losses: current.losses + (outcome === 'loss' ? 1 : 0),
    });
  }

  private accumulateSetRecord(
    records: Map<string, GridTeamRecord>,
    teamId: string,
    setWins: number,
    setLosses: number,
  ): void {
    const current = records.get(teamId) ?? {
      wins: 0,
      losses: 0,
      setWins: 0,
      setLosses: 0,
    };

    records.set(teamId, {
      ...current,
      setWins: current.setWins + setWins,
      setLosses: current.setLosses + setLosses,
    });
  }

  private isPlaceholderTeam(name: string): boolean {
    return /(^|\b)tbd(\b|$)/i.test(name.trim());
  }
}
