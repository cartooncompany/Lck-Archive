import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import { GridLckParser } from '../parser/grid-lck.parser';
import { RawLckSnapshotPayload } from '../types/lck-source.types';
import {
  GridConnection,
  GridLckSnapshotPayload,
  GridPlayerNode,
  GridSeriesNode,
  GridSeriesState,
} from '../types/grid-source.types';

const DEFAULT_GRID_API_URL = 'https://api.grid.gg';
const DEFAULT_GRID_TITLE_ID = '3';
const DEFAULT_GRID_TOURNAMENT_NAME_KEYWORD = 'LCK';
const DEFAULT_GRID_LOOKBACK_DAYS = 120;
const DEFAULT_GRID_LOOKAHEAD_DAYS = 120;
const DEFAULT_GRID_PAGE_SIZE = 50;
const DEFAULT_SERIES_STATE_CONCURRENCY = 8;
const DEFAULT_TEAM_QUERY_CONCURRENCY = 4;
const DEFAULT_GRID_REQUESTS_PER_MINUTE = 18;
const DEFAULT_GRID_RATE_LIMIT_WINDOW_MS = 60_000;
const GRID_API_KEY_MISSING_MESSAGE =
  'GRID API key is not configured. Set GRID_API_KEY before running GRID-based LCK sync.';

interface GridGraphqlError {
  message?: string;
  path?: Array<string | number>;
  extensions?: {
    code?: string;
    serviceName?: string;
    errorType?: string;
    errorDetail?: string;
  };
}

@Injectable()
export class GridLckClient {
  private readonly logger = new Logger(GridLckClient.name);
  private readonly axiosClient: AxiosInstance;
  private readonly centralDataUrl: string;
  private readonly seriesStateUrl: string;
  private readonly apiKey?: string;
  private readonly titleId: string;
  private readonly tournamentNameKeyword: string;
  private readonly lookbackDays: number;
  private readonly lookaheadDays: number;
  private readonly pageSize: number;
  private readonly seriesStateConcurrency: number;
  private readonly teamQueryConcurrency: number;
  private readonly requestsPerMinute: number;
  private readonly rateLimitWindowMs: number;
  private readonly requestTimestamps: number[] = [];
  private rateLimitChain = Promise.resolve();

  constructor(
    private readonly configService: ConfigService,
    private readonly gridLckParser: GridLckParser,
  ) {
    const gridApiBaseUrl =
      this.configService.get<string>('GRID_API_URL')?.trim() ??
      DEFAULT_GRID_API_URL;

    this.centralDataUrl =
      this.configService.get<string>('GRID_CENTRAL_DATA_URL')?.trim() ??
      `${gridApiBaseUrl}/central-data/graphql`;
    this.seriesStateUrl =
      this.configService.get<string>('GRID_SERIES_STATE_URL')?.trim() ??
      `${gridApiBaseUrl}/live-data-feed/series-state/graphql`;
    this.apiKey = this.configService.get<string>('GRID_API_KEY')?.trim();
    this.titleId =
      this.configService.get<string>('GRID_TITLE_ID')?.trim() ??
      DEFAULT_GRID_TITLE_ID;
    this.tournamentNameKeyword =
      this.configService
        .get<string>('GRID_TOURNAMENT_NAME_KEYWORD')
        ?.trim()
        .toLowerCase() ?? DEFAULT_GRID_TOURNAMENT_NAME_KEYWORD.toLowerCase();
    this.lookbackDays = this.toPositiveNumber(
      this.configService.get<string>('GRID_SERIES_LOOKBACK_DAYS'),
      DEFAULT_GRID_LOOKBACK_DAYS,
    );
    this.lookaheadDays = this.toPositiveNumber(
      this.configService.get<string>('GRID_SERIES_LOOKAHEAD_DAYS'),
      DEFAULT_GRID_LOOKAHEAD_DAYS,
    );
    this.pageSize = Math.min(
      this.toPositiveNumber(
        this.configService.get<string>('GRID_QUERY_PAGE_SIZE'),
        DEFAULT_GRID_PAGE_SIZE,
      ),
      DEFAULT_GRID_PAGE_SIZE,
    );
    this.seriesStateConcurrency = this.toPositiveNumber(
      this.configService.get<string>('GRID_SERIES_STATE_CONCURRENCY'),
      DEFAULT_SERIES_STATE_CONCURRENCY,
    );
    this.teamQueryConcurrency = this.toPositiveNumber(
      this.configService.get<string>('GRID_TEAM_QUERY_CONCURRENCY'),
      DEFAULT_TEAM_QUERY_CONCURRENCY,
    );
    this.requestsPerMinute = this.toPositiveNumber(
      this.configService.get<string>('GRID_REQUESTS_PER_MINUTE'),
      DEFAULT_GRID_REQUESTS_PER_MINUTE,
    );
    this.rateLimitWindowMs = this.toPositiveNumber(
      this.configService.get<string>('GRID_RATE_LIMIT_WINDOW_MS'),
      DEFAULT_GRID_RATE_LIMIT_WINDOW_MS,
    );

    this.axiosClient = axios.create({
      timeout: 15000,
      headers: this.apiKey
        ? {
            'x-api-key': this.apiKey,
            'Content-Type': 'application/json',
          }
        : undefined,
    });
  }

  hasApiKey(): boolean {
    return Boolean(this.apiKey);
  }

  async fetchSnapshot(): Promise<RawLckSnapshotPayload> {
    this.assertApiKeyConfigured();

    const series = await this.fetchSeries();
    const filteredSeries = series.filter((entry) =>
      entry.tournament?.name
        ?.toLowerCase()
        .includes(this.tournamentNameKeyword),
    );
    const teamIds = this.extractTeamIds(filteredSeries);
    const [playersByTeamId, statesBySeriesId] = await Promise.all([
      this.fetchPlayersByTeam(teamIds),
      this.fetchStatesBySeries(filteredSeries),
    ]);

    this.logger.log(
      `Fetched GRID LCK snapshot. series=${filteredSeries.length}, teams=${teamIds.length}, rosters=${Object.keys(playersByTeamId).length}, states=${Object.keys(statesBySeriesId).length}`,
    );

    return this.gridLckParser.parseSnapshot({
      series: filteredSeries,
      playersByTeamId,
      statesBySeriesId,
    });
  }

  private async fetchSeries(): Promise<GridSeriesNode[]> {
    const series: GridSeriesNode[] = [];
    let afterCursor: string | null = null;

    do {
      const data = await this.executeGraphql<{
        allSeries?: GridConnection<GridSeriesNode> | null;
      }>(this.centralDataUrl, this.buildAllSeriesQuery(afterCursor));
      const connection = data.allSeries;

      series.push(...this.extractNodes<GridSeriesNode>(connection));
      afterCursor =
        connection?.pageInfo?.hasNextPage && connection.pageInfo.endCursor
          ? connection.pageInfo.endCursor
          : null;
    } while (afterCursor);

    return series;
  }

  private async fetchPlayersByTeam(
    teamIds: string[],
  ): Promise<Record<string, GridPlayerNode[]>> {
    const entries = await this.mapWithConcurrency(
      teamIds,
      this.teamQueryConcurrency,
      async (teamId) => {
        try {
          const roster = await this.fetchPlayersForTeam(teamId);
          return [teamId, roster] as const;
        } catch (error) {
          const message =
            error instanceof Error
              ? error.message
              : 'Unknown GRID roster error';

          this.logger.warn(
            `Failed to fetch GRID roster for team ${teamId}: ${message}`,
          );
          return [teamId, []] as const;
        }
      },
    );

    return Object.fromEntries(entries);
  }

  private async fetchPlayersForTeam(teamId: string): Promise<GridPlayerNode[]> {
    const roster: GridPlayerNode[] = [];
    let afterCursor: string | null = null;

    do {
      const data = await this.executeGraphql<{
        players?: GridConnection<GridPlayerNode> | null;
      }>(this.centralDataUrl, this.buildPlayersQuery(teamId, afterCursor));
      const connection = data.players;

      roster.push(...this.extractNodes<GridPlayerNode>(connection));
      afterCursor =
        connection?.pageInfo?.hasNextPage && connection.pageInfo.endCursor
          ? connection.pageInfo.endCursor
          : null;
    } while (afterCursor);

    return roster;
  }

  private async fetchStatesBySeries(
    series: GridSeriesNode[],
  ): Promise<Record<string, GridSeriesState | null>> {
    const entries = await this.mapWithConcurrency(
      series.map((entry) => entry.id),
      this.seriesStateConcurrency,
      async (seriesId) => {
        try {
          const state = await this.fetchSeriesState(seriesId);
          return [seriesId, state] as const;
        } catch (error) {
          const message =
            error instanceof Error
              ? error.message
              : 'Unknown GRID series-state error';

          this.logger.warn(
            `Failed to fetch GRID series state for ${seriesId}: ${message}`,
          );
          return [seriesId, null] as const;
        }
      },
    );

    return Object.fromEntries(entries);
  }

  private async fetchSeriesState(
    seriesId: string,
  ): Promise<GridSeriesState | null> {
    const data = await this.executeGraphql<{
      seriesState?: GridSeriesState | null;
    }>(this.seriesStateUrl, this.buildSeriesStateQuery(seriesId));

    return data.seriesState ?? null;
  }

  private async executeGraphql<T>(url: string, query: string): Promise<T> {
    await this.waitForRateLimitSlot();

    const response = await this.axiosClient.post<{
      data?: T;
      errors?: GridGraphqlError[];
    }>(url, { query });

    if (response.data.errors?.length) {
      throw new Error(this.formatGraphqlErrors(response.data.errors));
    }

    if (!response.data.data) {
      throw new Error('GRID GraphQL response did not include data');
    }

    return response.data.data;
  }

  private async waitForRateLimitSlot(): Promise<void> {
    const reservation = this.rateLimitChain.then(() =>
      this.reserveRateLimitSlot(),
    );

    this.rateLimitChain = reservation.catch(() => undefined);

    return reservation;
  }

  private async reserveRateLimitSlot(): Promise<void> {
    while (true) {
      const now = Date.now();
      const windowStart = now - this.rateLimitWindowMs;

      while (
        this.requestTimestamps.length > 0 &&
        this.requestTimestamps[0] <= windowStart
      ) {
        this.requestTimestamps.shift();
      }

      if (this.requestTimestamps.length < this.requestsPerMinute) {
        this.requestTimestamps.push(now);
        return;
      }

      const oldestRequestAt = this.requestTimestamps[0];
      const waitMs = Math.max(
        oldestRequestAt + this.rateLimitWindowMs - now + 1,
        1,
      );

      await this.delay(waitMs);
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  private formatGraphqlErrors(errors: GridGraphqlError[]): string {
    return errors
      .map((error) => {
        const parts = [
          error.extensions?.errorType,
          error.extensions?.errorDetail,
          error.extensions?.code,
          error.extensions?.serviceName,
          error.path?.length ? `path=${error.path.join('.')}` : undefined,
          error.message ?? 'Unknown GraphQL error',
        ].filter(Boolean);

        return parts.join(': ');
      })
      .join('; ');
  }

  private buildAllSeriesQuery(afterCursor: string | null): string {
    const range = this.getSeriesDateRange();

    return `
      query AllSeries {
        allSeries(
          filter: {
            titleId: ${JSON.stringify(this.titleId)}
            startTimeScheduled: {
              gte: ${JSON.stringify(range.gte)}
              lte: ${JSON.stringify(range.lte)}
            }
          }
          orderBy: StartTimeScheduled
          first: ${this.pageSize}
          after: ${afterCursor ? JSON.stringify(afterCursor) : 'null'}
        ) {
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              startTimeScheduled
              tournament {
                id
                name
              }
              title {
                id
                nameShortened
              }
              teams {
                baseInfo {
                  id
                  name
                  logoUrl
                }
              }
            }
          }
        }
      }
    `;
  }

  private buildPlayersQuery(
    teamId: string,
    afterCursor: string | null,
  ): string {
    return `
      query Players {
        players(
          filter: {
            teamIdFilter: {
              id: ${JSON.stringify(teamId)}
            }
          }
          first: ${this.pageSize}
          after: ${afterCursor ? JSON.stringify(afterCursor) : 'null'}
        ) {
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              nickname
              roles {
                id
                name
                title {
                  name
                }
              }
            }
          }
        }
      }
    `;
  }

  private buildSeriesStateQuery(seriesId: string): string {
    return `
      query SeriesState {
        seriesState(id: ${JSON.stringify(seriesId)}) {
          id
          format
          valid
          started
          finished
          forfeited
          startedAt
          updatedAt
          duration
          teams {
            id
            name
            won
            score
            players {
              id
              name
              participationStatus
            }
          }
          games {
            id
            sequenceNumber
            started
            finished
            forfeited
            startedAt
            duration
            map {
              id
              name
            }
            teams {
              id
              name
              side
              won
              score
              players {
                id
                name
                participationStatus
                character {
                  id
                  name
                }
                roles {
                  id
                }
                kills
                deaths
                killAssistsGiven
                ... on GamePlayerStateLol {
                  totalMoneyEarned
                  damageDealt
                  damageTaken
                  visionScore
                  kdaRatio
                  killParticipation
                }
              }
            }
            draftActions {
              id
              type
              sequenceNumber
              drafter {
                id
                type
              }
              draftable {
                id
                type
                name
              }
            }
          }
        }
      }
    `;
  }

  private getSeriesDateRange(): { gte: string; lte: string } {
    const now = new Date();
    const gte = new Date(now);
    const lte = new Date(now);

    gte.setUTCDate(gte.getUTCDate() - this.lookbackDays);
    lte.setUTCDate(lte.getUTCDate() + this.lookaheadDays);

    return {
      gte: gte.toISOString(),
      lte: lte.toISOString(),
    };
  }

  private extractTeamIds(series: GridSeriesNode[]): string[] {
    const teamIds = new Set<string>();

    for (const entry of series) {
      for (const competitor of entry.teams ?? []) {
        const team = competitor.baseInfo;

        if (!team || /(^|\b)tbd(\b|$)/i.test(team.name)) {
          continue;
        }

        teamIds.add(team.id);
      }
    }

    return [...teamIds];
  }

  private extractNodes<TNode>(
    connection?: GridConnection<TNode> | null,
  ): TNode[] {
    return (connection?.edges ?? []).flatMap((edge) =>
      edge?.node ? [edge.node] : [],
    );
  }

  private async mapWithConcurrency<TValue, TResult>(
    values: TValue[],
    concurrency: number,
    mapper: (value: TValue) => Promise<TResult>,
  ): Promise<TResult[]> {
    const results: TResult[] = new Array(values.length);
    let nextIndex = 0;

    const workers = Array.from(
      { length: Math.min(concurrency, values.length) },
      async () => {
        while (true) {
          const currentIndex = nextIndex;
          nextIndex += 1;

          if (currentIndex >= values.length) {
            return;
          }

          results[currentIndex] = await mapper(values[currentIndex]);
        }
      },
    );

    await Promise.all(workers);

    return results;
  }

  private assertApiKeyConfigured(): void {
    if (!this.apiKey) {
      throw new Error(GRID_API_KEY_MISSING_MESSAGE);
    }
  }

  private toPositiveNumber(
    value: string | undefined,
    fallback: number,
  ): number {
    const parsed = Number(value);

    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
  }
}
