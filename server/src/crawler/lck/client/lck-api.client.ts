import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import {
  LolesportsApiResponse,
  LolesportsSchedule,
  LolesportsScheduleData,
  LolesportsSnapshotPayload,
  LolesportsStandingsData,
  LolesportsStandingsEntry,
  LolesportsTeamData,
  LolesportsTeamDetails,
} from '../types/lck-source.types';

const DEFAULT_BASE_URL = 'https://esports-api.lolesports.com/persisted/gw';
const DEFAULT_LOCALE = 'ko-KR';
const DEFAULT_LEAGUE_ID = '98767991310872058';
const DEFAULT_TOURNAMENT_ID = '113503260417890076';
const DEFAULT_SCHEDULE_PAGE_LIMIT = 12;
const MISSING_API_KEY_MESSAGE =
  'LOLESPORTS_API_KEY is not configured. Set it in the runtime environment before running LCK sync.';

@Injectable()
export class LckApiClient {
  private readonly logger = new Logger(LckApiClient.name);
  private readonly axiosClient: AxiosInstance;
  private readonly apiKey?: string;
  private readonly locale: string;
  private readonly leagueId: string;
  private readonly tournamentId: string;
  private readonly schedulePageLimit: number;

  constructor(private readonly configService: ConfigService) {
    const baseUrl =
      this.configService.get<string>('LOLESPORTS_API_URL') ??
      this.configService.get<string>('LCK_API_BASE_URL') ??
      DEFAULT_BASE_URL;
    this.apiKey = this.configService.get<string>('LOLESPORTS_API_KEY')?.trim();

    this.locale =
      this.configService.get<string>('LOLESPORTS_API_LOCALE') ?? DEFAULT_LOCALE;
    this.leagueId =
      this.configService.get<string>('LCK_LEAGUE_ID') ?? DEFAULT_LEAGUE_ID;
    this.tournamentId =
      this.configService.get<string>('LCK_TOURNAMENT_ID') ??
      DEFAULT_TOURNAMENT_ID;
    this.schedulePageLimit = Number(
      this.configService.get<string>('LCK_SCHEDULE_PAGE_LIMIT') ??
        DEFAULT_SCHEDULE_PAGE_LIMIT,
    );

    this.axiosClient = axios.create({
      baseURL: baseUrl,
      timeout: 10000,
      headers: this.apiKey ? { 'x-api-key': this.apiKey } : undefined,
    });
  }

  async fetchSnapshot(): Promise<LolesportsSnapshotPayload> {
    this.assertApiKeyConfigured();
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

  private assertApiKeyConfigured(): void {
    if (!this.apiKey) {
      throw new Error(MISSING_API_KEY_MESSAGE);
    }
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
    const initialPage = await this.fetchSchedulePage();
    const events = [...initialPage.events];
    const seenEventKeys = new Set(
      events.map((event) => this.toEventKey(event)),
    );

    await this.collectSchedulePages(
      initialPage.pages.older,
      'older',
      events,
      seenEventKeys,
    );
    await this.collectSchedulePages(
      initialPage.pages.newer,
      'newer',
      events,
      seenEventKeys,
    );

    return events.sort(
      (left, right) =>
        new Date(left.startTime).getTime() -
        new Date(right.startTime).getTime(),
    );
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

  private async fetchSchedulePage(
    pageToken?: string,
  ): Promise<LolesportsSchedule> {
    const response = await this.axiosClient.get<
      LolesportsApiResponse<LolesportsScheduleData>
    >('/getSchedule', {
      params: {
        hl: this.locale,
        leagueId: this.leagueId,
        ...(pageToken ? { pageToken } : {}),
      },
    });

    return response.data.data.schedule;
  }

  private async collectSchedulePages(
    initialToken: string | null | undefined,
    direction: 'older' | 'newer',
    events: LolesportsScheduleData['schedule']['events'],
    seenEventKeys: Set<string>,
  ): Promise<void> {
    let currentToken = initialToken;
    let pageCount = 0;
    const seenTokens = new Set<string>();

    while (
      currentToken &&
      pageCount < this.schedulePageLimit &&
      !seenTokens.has(currentToken)
    ) {
      seenTokens.add(currentToken);
      const page = await this.fetchSchedulePage(currentToken);

      for (const event of page.events) {
        const eventKey = this.toEventKey(event);

        if (seenEventKeys.has(eventKey)) {
          continue;
        }

        seenEventKeys.add(eventKey);
        events.push(event);
      }

      currentToken = page.pages[direction];
      pageCount += 1;
    }

    if (currentToken) {
      this.logger.warn(
        `Schedule pagination stopped before exhaustion. direction=${direction}, pageLimit=${this.schedulePageLimit}`,
      );
    }
  }

  private toEventKey(
    event: LolesportsScheduleData['schedule']['events'][number],
  ) {
    return (
      event.match?.id ??
      `${event.type}:${event.startTime}:${event.blockName ?? ''}:${event.league.slug}`
    );
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
