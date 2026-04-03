import { PlayerPosition } from '@prisma/client';
import { LckParser } from './lck.parser';
import { LolesportsSnapshotPayload } from '../types/lck-source.types';

describe('LckParser', () => {
  const parser = new LckParser();

  it('parses LoL Esports API payload into crawler snapshot shape', () => {
    const payload: LolesportsSnapshotPayload = {
      standings: [
        {
          stages: [
            {
              id: 'stage-1',
              name: '정규 리그',
              slug: 'regular_season',
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
                          image: 'http://static.lolesports.com/teams/t1.png',
                          record: {
                            wins: 2,
                            losses: 0,
                          },
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
                          image: 'http://static.lolesports.com/teams/gen.png',
                          record: {
                            wins: 0,
                            losses: 2,
                          },
                        },
                      ],
                    },
                  ],
                  matches: [
                    {
                      id: 'match-1',
                      state: 'completed',
                      teams: [
                        {
                          id: 'team-1',
                          slug: 't1',
                          name: 'T1',
                          code: 'T1',
                          image: 'http://static.lolesports.com/teams/t1.png',
                          result: {
                            outcome: 'win',
                            gameWins: 2,
                          },
                        },
                        {
                          id: 'team-2',
                          slug: 'geng',
                          name: 'Gen.G Esports',
                          code: 'GEN',
                          image: 'http://static.lolesports.com/teams/gen.png',
                          result: {
                            outcome: 'loss',
                            gameWins: 1,
                          },
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
      scheduleEvents: [
        {
          startTime: '2026-03-30T09:00:00Z',
          state: 'completed',
          type: 'match',
          blockName: '1주 차',
          league: {
            name: 'LCK',
            slug: 'lck',
          },
          match: {
            id: 'match-1',
            teams: [
              {
                name: 'T1',
                code: 'T1',
                image: 'https://example.com/t1.png',
                result: {
                  outcome: 'win',
                  gameWins: 2,
                },
              },
              {
                name: 'Gen.G Esports',
                code: 'GEN',
                image: 'https://example.com/gen.png',
                result: {
                  outcome: 'loss',
                  gameWins: 1,
                },
              },
            ],
          },
        },
      ],
      teams: [
        {
          id: 'team-1',
          slug: 't1',
          name: 'T1',
          code: 'T1',
          image: 'http://static.lolesports.com/teams/t1.png',
          players: [
            {
              id: 'player-1',
              summonerName: 'Faker',
              firstName: 'Sang-hyeok',
              lastName: 'Lee',
              image: 'http://static.lolesports.com/players/faker.png',
              role: 'mid',
            },
          ],
        },
        {
          id: 'team-2',
          slug: 'geng',
          name: 'Gen.G Esports',
          code: 'GEN',
          image: 'http://static.lolesports.com/teams/gen.png',
          players: [
            {
              id: 'player-2',
              summonerName: 'Chovy',
              firstName: 'Ji-hun',
              lastName: 'Jung',
              image: 'http://static.lolesports.com/players/chovy.png',
              role: 'mid',
            },
          ],
        },
      ],
    };

    const snapshot = parser.parseSnapshot(payload);

    expect(snapshot.teams).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          externalId: 'team-1',
          name: 'T1',
          shortName: 'T1',
          logoUrl: 'https://static.lolesports.com/teams/t1.png',
          rank: 1,
          wins: 2,
          losses: 0,
          setWins: 2,
          setLosses: 1,
        }),
        expect.objectContaining({
          externalId: 'team-2',
          name: 'Gen.G Esports',
          shortName: 'GEN',
          logoUrl: 'https://static.lolesports.com/teams/gen.png',
          rank: 2,
          wins: 0,
          losses: 2,
          setWins: 1,
          setLosses: 2,
        }),
      ]),
    );

    expect(snapshot.players).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          externalId: 'player-1',
          name: 'Faker',
          teamExternalId: 'team-1',
          position: PlayerPosition.MID,
          profileImageUrl: 'https://static.lolesports.com/players/faker.png',
          realName: 'Sang-hyeok Lee',
        }),
      ]),
    );

    expect(snapshot.matches).toEqual([
      expect.objectContaining({
        externalId: 'match-1',
        split: '정규 리그',
        stage: '1주 차',
        homeTeamExternalId: 'team-1',
        awayTeamExternalId: 'team-2',
        homeScore: 2,
        awayScore: 1,
      }),
    ]);
  });
});
