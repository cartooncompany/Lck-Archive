import { Injectable, Logger } from '@nestjs/common';
import { MatchStatus, PlayerPosition } from '@prisma/client';
import {
  LolesportsScheduleEvent,
  LolesportsSnapshotPayload,
  LolesportsStandingStage,
  LolesportsTeamDetails,
  RawLckMatchPayload,
  RawLckPlayerPayload,
  RawLckSnapshotPayload,
  RawLckTeamPayload,
} from '../types/lck-source.types';

interface RankingTeamStat {
  externalId: string;
  rank: number;
  wins: number;
  losses: number;
}

interface SetRecord {
  setWins: number;
  setLosses: number;
}

interface MatchStageMeta {
  split: string;
  stage: string;
}

@Injectable()
export class LckParser {
  private readonly logger = new Logger(LckParser.name);

  parseSnapshot(payload: LolesportsSnapshotPayload): RawLckSnapshotPayload {
    const standingsStage = this.findPrimaryStage(payload.standings);
    const rankingStats = this.buildRankingStats(standingsStage);
    const setRecords = this.buildSetRecords(standingsStage);
    const matchStages = this.buildMatchStages(standingsStage);
    const teams = this.parseTeams(payload.teams, rankingStats, setRecords);
    const teamIdByCode = new Map(
      teams.map((team) => [team.shortName, team.externalId]),
    );
    const teamIdByName = new Map(
      teams.map((team) => [team.name, team.externalId]),
    );

    return {
      teams,
      players: this.parsePlayers(payload.teams),
      matches: this.parseMatches(
        payload.scheduleEvents,
        teamIdByCode,
        teamIdByName,
        matchStages,
        standingsStage?.name ?? 'LCK',
      ),
    };
  }

  private parseTeams(
    teams: LolesportsTeamDetails[],
    rankingStats: Map<string, RankingTeamStat>,
    setRecords: Map<string, SetRecord>,
  ): RawLckTeamPayload[] {
    return teams.map((team) => {
      const ranking = rankingStats.get(team.id);
      const setRecord = setRecords.get(team.id);

      return {
        externalId: team.id,
        name: team.name,
        shortName: team.code,
        logoUrl: this.normalizeMediaUrl(team.image),
        rank: ranking?.rank ?? null,
        wins: ranking?.wins ?? 0,
        losses: ranking?.losses ?? 0,
        setWins: setRecord?.setWins ?? 0,
        setLosses: setRecord?.setLosses ?? 0,
      };
    });
  }

  private parsePlayers(teams: LolesportsTeamDetails[]): RawLckPlayerPayload[] {
    const players = new Map<string, RawLckPlayerPayload>();

    for (const team of teams) {
      for (const player of team.players) {
        players.set(player.id, {
          externalId: player.id,
          name: player.summonerName,
          teamExternalId: team.id,
          position: this.toPlayerPosition(player.role),
          profileImageUrl: this.normalizeMediaUrl(player.image),
          realName: this.toRealName(player.firstName, player.lastName),
          nationality: null,
          birthDate: null,
          recentMatchCount: 0,
        });
      }
    }

    return [...players.values()];
  }

  private parseMatches(
    scheduleEvents: LolesportsScheduleEvent[],
    teamIdByCode: Map<string, string>,
    teamIdByName: Map<string, string>,
    matchStages: Map<string, MatchStageMeta>,
    defaultSplit: string,
  ): RawLckMatchPayload[] {
    const matches: RawLckMatchPayload[] = [];

    for (const event of scheduleEvents) {
      if (
        event.type !== 'match' ||
        !event.match ||
        event.match.teams.length < 2
      ) {
        continue;
      }

      const [homeTeam, awayTeam] = event.match.teams;
      const homeTeamExternalId = this.resolveTeamId(
        homeTeam.code,
        homeTeam.name,
        teamIdByCode,
        teamIdByName,
      );
      const awayTeamExternalId = this.resolveTeamId(
        awayTeam.code,
        awayTeam.name,
        teamIdByCode,
        teamIdByName,
      );

      if (!homeTeamExternalId || !awayTeamExternalId) {
        this.logger.warn(
          `Skip schedule event because team id could not be resolved: ${event.match.id}`,
        );
        continue;
      }

      const matchStage = matchStages.get(event.match.id);
      const winnerTeam = [homeTeam, awayTeam].find(
        (team) => team.result?.outcome === 'win',
      );

      matches.push({
        externalId: event.match.id,
        scheduledAt: event.startTime,
        seasonYear: new Date(event.startTime).getUTCFullYear(),
        split: matchStage?.split ?? defaultSplit,
        stage: event.blockName ?? matchStage?.stage ?? defaultSplit,
        matchNumber: null,
        homeTeamExternalId,
        awayTeamExternalId,
        homeScore: homeTeam.result?.gameWins ?? 0,
        awayScore: awayTeam.result?.gameWins ?? 0,
        winnerTeamExternalId: winnerTeam
          ? this.resolveTeamId(
              winnerTeam.code,
              winnerTeam.name,
              teamIdByCode,
              teamIdByName,
            )
          : null,
        status: this.toMatchStatus(event.state),
        vodUrl: null,
      });
    }

    return matches;
  }

  private findPrimaryStage(standings: LolesportsSnapshotPayload['standings']) {
    return standings
      .flatMap((entry) => entry.stages)
      .find((stage) =>
        stage.sections.some((section) => section.rankings.length > 0),
      );
  }

  private buildRankingStats(
    stage?: LolesportsStandingStage,
  ): Map<string, RankingTeamStat> {
    const rankingStats = new Map<string, RankingTeamStat>();

    if (!stage) {
      return rankingStats;
    }

    for (const section of stage.sections) {
      for (const ranking of section.rankings) {
        for (const team of ranking.teams) {
          rankingStats.set(team.id, {
            externalId: team.id,
            rank: ranking.ordinal,
            wins: team.record?.wins ?? 0,
            losses: team.record?.losses ?? 0,
          });
        }
      }
    }

    return rankingStats;
  }

  private buildSetRecords(
    stage?: LolesportsStandingStage,
  ): Map<string, SetRecord> {
    const setRecords = new Map<string, SetRecord>();

    if (!stage) {
      return setRecords;
    }

    for (const section of stage.sections) {
      for (const match of section.matches) {
        if (match.state !== 'completed' || match.teams.length < 2) {
          continue;
        }

        const [firstTeam, secondTeam] = match.teams;
        this.accumulateSetRecord(
          setRecords,
          firstTeam.id,
          firstTeam.result?.gameWins ?? 0,
          secondTeam.result?.gameWins ?? 0,
        );
        this.accumulateSetRecord(
          setRecords,
          secondTeam.id,
          secondTeam.result?.gameWins ?? 0,
          firstTeam.result?.gameWins ?? 0,
        );
      }
    }

    return setRecords;
  }

  private buildMatchStages(
    stage?: LolesportsStandingStage,
  ): Map<string, MatchStageMeta> {
    const matchStages = new Map<string, MatchStageMeta>();

    if (!stage) {
      return matchStages;
    }

    for (const section of stage.sections) {
      for (const match of section.matches) {
        matchStages.set(match.id, {
          split: stage.name,
          stage: section.name,
        });
      }
    }

    return matchStages;
  }

  private resolveTeamId(
    code: string,
    name: string,
    teamIdByCode: Map<string, string>,
    teamIdByName: Map<string, string>,
  ): string | null {
    return teamIdByCode.get(code) ?? teamIdByName.get(name) ?? null;
  }

  private toPlayerPosition(role?: string | null): PlayerPosition {
    switch (role?.toLowerCase()) {
      case 'top':
        return PlayerPosition.TOP;
      case 'jungle':
        return PlayerPosition.JUNGLE;
      case 'mid':
        return PlayerPosition.MID;
      case 'bottom':
      case 'adc':
        return PlayerPosition.ADC;
      case 'support':
        return PlayerPosition.SUPPORT;
      case 'coach':
        return PlayerPosition.COACH;
      case 'substitute':
        return PlayerPosition.SUBSTITUTE;
      default:
        return PlayerPosition.FLEX;
    }
  }

  private toRealName(
    firstName?: string | null,
    lastName?: string | null,
  ): string | null {
    const fullName = [firstName, lastName].filter(Boolean).join(' ').trim();

    return fullName.length > 0 ? fullName : null;
  }

  private toMatchStatus(state: string): MatchStatus {
    switch (state) {
      case 'completed':
        return MatchStatus.COMPLETED;
      case 'canceled':
        return MatchStatus.CANCELED;
      default:
        return MatchStatus.SCHEDULED;
    }
  }

  private normalizeMediaUrl(url?: string | null): string | null {
    const normalizedUrl = url?.trim();

    if (!normalizedUrl) {
      return null;
    }

    try {
      const parsedUrl = new URL(normalizedUrl);

      if (
        parsedUrl.protocol === 'http:' &&
        parsedUrl.hostname === 'static.lolesports.com'
      ) {
        parsedUrl.protocol = 'https:';
      }

      return parsedUrl.toString();
    } catch {
      return normalizedUrl;
    }
  }

  private accumulateSetRecord(
    setRecords: Map<string, SetRecord>,
    teamId: string,
    setWins: number,
    setLosses: number,
  ): void {
    const currentRecord = setRecords.get(teamId) ?? {
      setWins: 0,
      setLosses: 0,
    };

    setRecords.set(teamId, {
      setWins: currentRecord.setWins + setWins,
      setLosses: currentRecord.setLosses + setLosses,
    });
  }
}
