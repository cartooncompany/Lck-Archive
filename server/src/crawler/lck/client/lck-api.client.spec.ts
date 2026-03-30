import { ConfigService } from '@nestjs/config';
import { LckApiClient } from './lck-api.client';
import {
  LolesportsApiResponse,
  LolesportsScheduleData,
  LolesportsStandingsData,
  LolesportsTeamData,
} from '../types/lck-source.types';

describe('LckApiClient', () => {
  it('collects paginated schedule pages and deduplicates events', async () => {
    const client = new LckApiClient(
      new ConfigService({
        LCK_SCHEDULE_PAGE_LIMIT: 3,
      }),
    );

    const get = jest.fn(
      async (
        url: string,
        options?: {
          params?: Record<string, string>;
        },
      ) => {
        if (url === '/getStandings') {
          const response: LolesportsApiResponse<LolesportsStandingsData> = {
            data: {
              standings: [
                {
                  stages: [
                    {
                      id: 'stage-1',
                      name: '정규 리그',
                      slug: 'regular-season',
                      sections: [
                        {
                          name: '정규 리그',
                          rankings: [
                            {
                              ordinal: 1,
                              teams: [
                                {
                                  id: 'team-1',
                                  slug: 't1',
                                  name: 'T1',
                                  code: 'T1',
                                },
                              ],
                            },
                            {
                              ordinal: 2,
                              teams: [
                                {
                                  id: 'team-2',
                                  slug: 'geng',
                                  name: 'Gen.G Esports',
                                  code: 'GEN',
                                },
                              ],
                            },
                          ],
                          matches: [],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          };

          return { data: response };
        }

        if (url === '/getSchedule') {
          return {
            data: buildScheduleResponse(options?.params?.pageToken),
          };
        }

        if (url === '/getTeams') {
          const teamId = options?.params?.id;
          const response: LolesportsApiResponse<LolesportsTeamData> = {
            data: {
              teams: [
                {
                  id: teamId ?? 'missing-team-id',
                  slug: teamId ?? 'missing-team-id',
                  name: teamId === 'team-1' ? 'T1' : 'Gen.G Esports',
                  code: teamId === 'team-1' ? 'T1' : 'GEN',
                  players: [],
                },
              ],
            },
          };

          return { data: response };
        }

        throw new Error(`Unexpected request: ${url}`);
      },
    );

    (client as unknown as { axiosClient: { get: typeof get } }).axiosClient = {
      get,
    };

    const snapshot = await client.fetchSnapshot();

    expect(snapshot.scheduleEvents.map((event) => event.match?.id)).toEqual([
      'match-older',
      'match-initial',
      'match-newer',
    ]);
    expect(snapshot.teams).toHaveLength(2);
    expect(
      get.mock.calls.filter(([url]) => url === '/getSchedule'),
    ).toHaveLength(3);
  });
});

function buildScheduleResponse(
  pageToken?: string,
): LolesportsApiResponse<LolesportsScheduleData> {
  if (!pageToken) {
    return {
      data: {
        schedule: {
          pages: {
            older: 'older-token',
            newer: 'newer-token',
          },
          events: [
            createScheduleEvent('match-initial', '2026-04-02T10:00:00Z'),
          ],
        },
      },
    };
  }

  if (pageToken === 'older-token') {
    return {
      data: {
        schedule: {
          pages: {
            older: null,
            newer: null,
          },
          events: [
            createScheduleEvent('match-older', '2026-04-01T10:00:00Z'),
            createScheduleEvent('match-initial', '2026-04-02T10:00:00Z'),
          ],
        },
      },
    };
  }

  if (pageToken === 'newer-token') {
    return {
      data: {
        schedule: {
          pages: {
            older: null,
            newer: null,
          },
          events: [
            createScheduleEvent('match-initial', '2026-04-02T10:00:00Z'),
            createScheduleEvent('match-newer', '2026-04-03T10:00:00Z'),
          ],
        },
      },
    };
  }

  throw new Error(`Unexpected page token: ${pageToken}`);
}

function createScheduleEvent(matchId: string, startTime: string) {
  return {
    startTime,
    state: 'unstarted',
    type: 'match',
    blockName: '1주 차',
    league: {
      name: 'LCK',
      slug: 'lck',
    },
    match: {
      id: matchId,
      teams: [
        {
          name: 'T1',
          code: 'T1',
        },
        {
          name: 'Gen.G Esports',
          code: 'GEN',
        },
      ],
    },
  };
}
