import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import {
  LolesportsApiResponse,
  LolesportsScheduleData,
  LolesportsSnapshotPayload,
  LolesportsStandingsData,
  LolesportsStandingsEntry,
  LolesportsTeamData,
  LolesportsTeamDetails,
} from '../types/lck-source.types';

const DEFAULT_BASE_URL = 'https://esports-api.lolesports.com/persisted/gw';
const DEFAULT_API_KEY = '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z';
const DEFAULT_LOCALE = 'ko-KR';
const DEFAULT_LEAGUE_ID = '98767991310872058';
const DEFAULT_TOURNAMENT_ID = '113503260417890076';

@Injectable()
export class LckApiClient {
  private readonly logger = new Logger(LckApiClient.name);
  private readonly axiosClient: AxiosInstance;
  private readonly locale: string;
  private readonly leagueId: string;
  private readonly tournamentId: string;

  constructor(private readonly configService: ConfigService) {
    const baseUrl =
      this.configService.get<string>('LOLESPORTS_API_URL') ??
      this.configService.get<string>('LCK_API_BASE_URL') ??
      DEFAULT_BASE_URL;
    const apiKey =
      this.configService.get<string>('LOLESPORTS_API_KEY') ?? DEFAULT_API_KEY;

    this.locale =
      this.configService.get<string>('LOLESPORTS_API_LOCALE') ?? DEFAULT_LOCALE;
    this.leagueId =
      this.configService.get<string>('LCK_LEAGUE_ID') ?? DEFAULT_LEAGUE_ID;
    this.tournamentId =
      this.configService.get<string>('LCK_TOURNAMENT_ID') ??
      DEFAULT_TOURNAMENT_ID;

    this.axiosClient = axios.create({
      baseURL: baseUrl,
      timeout: 10000,
      headers: {
        'x-api-key': apiKey,
      },
    });
  }

  async fetchSnapshot(): Promise<LolesportsSnapshotPayload> {
    const [standings, schedule] = await Promise.all([
      this.fetchStandings(),
      this.fetchSchedule(),
    ]);
    const teamIds = this.extractTeamIds(standings);
    const teams = (
      await Promise.all(teamIds.map((teamId) => this.fetchTeam(teamId)))
    ).flatMap((entry) => entry.teams);

    this.logger.log(
      `Fetched snapshot from LoL Esports API. standings=${standings.length}, scheduleEvents=${schedule.length}, teams=${teams.length}`,
    );

    return {
      standings,
      scheduleEvents: schedule,
      teams: this.deduplicateTeams(teams),
    };
  }

  private async fetchStandings(): Promise<LolesportsStandingsEntry[]> {
    const response = await this.axiosClient.get<
      LolesportsApiResponse<LolesportsStandingsData>
    >('/getStandings', {
      params: {
        hl: this.locale,
        tournamentId: this.tournamentId,
      },
    });

    return response.data.data.standings;
  }

  private async fetchSchedule(): Promise<
    LolesportsScheduleData['schedule']['events']
  > {
    const response = await this.axiosClient.get<
      LolesportsApiResponse<LolesportsScheduleData>
    >('/getSchedule', {
      params: {
        hl: this.locale,
        leagueId: this.leagueId,
      },
    });

    return response.data.data.schedule.events;
  }

  private async fetchTeam(teamId: string): Promise<LolesportsTeamData> {
    const response = await this.axiosClient.get<
      LolesportsApiResponse<LolesportsTeamData>
    >('/getTeams', {
      params: {
        hl: this.locale,
        id: teamId,
      },
    });

    return response.data.data;
  }

  private extractTeamIds(standings: LolesportsStandingsEntry[]): string[] {
    const teamIds = new Set<string>();

    for (const standing of standings) {
      for (const stage of standing.stages) {
        for (const section of stage.sections) {
          for (const ranking of section.rankings) {
            for (const team of ranking.teams) {
              teamIds.add(team.id);
            }
          }
        }
      }
    }

    return [...teamIds];
  }

  private deduplicateTeams(
    teams: LolesportsTeamDetails[],
  ): LolesportsTeamDetails[] {
    return [...new Map(teams.map((team) => [team.id, team])).values()];
  }
}
