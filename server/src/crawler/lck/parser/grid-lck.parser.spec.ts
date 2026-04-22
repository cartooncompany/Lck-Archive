import { MatchStatus, PlayerPosition } from '@prisma/client';
import { GridLckParser } from './grid-lck.parser';
import { GridLckSnapshotPayload } from '../types/grid-source.types';

describe('GridLckParser', () => {
  const parser = new GridLckParser();

  it('parses GRID snapshot payload into the internal LCK snapshot shape', () => {
    const payload: GridLckSnapshotPayload = {
      series: [
        {
          id: 'series-1',
          startTimeScheduled: '2026-04-01T09:00:00Z',
          tournament: {
            id: 'tournament-1',
            name: 'LCK Spring 2026',
          },
          title: {
            id: '3',
            nameShortened: 'LoL',
          },
          teams: [
            {
              baseInfo: {
                id: 'team-1',
                name: 'T1',
                logoUrl: 'https://cdn.example.com/t1.png',
              },
            },
            {
              baseInfo: {
                id: 'team-2',
                name: 'Gen.G Esports',
                logoUrl: 'https://cdn.example.com/geng.png',
              },
            },
          ],
        },
        {
          id: 'series-2',
          startTimeScheduled: '2026-04-05T09:00:00Z',
          tournament: {
            id: 'tournament-1',
            name: 'LCK Spring 2026',
          },
          teams: [
            {
              baseInfo: {
                id: 'team-1',
                name: 'T1',
                logoUrl: 'https://cdn.example.com/t1.png',
              },
            },
            {
              baseInfo: {
                id: 'team-3',
                name: 'KT Rolster',
                logoUrl: 'https://cdn.example.com/kt.png',
              },
            },
          ],
        },
        {
          id: 'series-3',
          startTimeScheduled: '2026-04-07T09:00:00Z',
          tournament: {
            id: 'tournament-1',
            name: 'LCK Spring 2026',
          },
          teams: [
            {
              baseInfo: {
                id: 'team-3',
                name: 'KT Rolster',
                logoUrl: 'https://cdn.example.com/kt.png',
              },
            },
            {
              baseInfo: {
                id: 'team-tbd',
                name: 'TBD',
                logoUrl: null,
              },
            },
          ],
        },
      ],
      playersByTeamId: {
        'team-1': [
          {
            id: 'player-1',
            nickname: 'Faker',
            roles: [{ name: 'mid' }],
          },
        ],
        'team-2': [
          {
            id: 'player-2',
            nickname: 'Chovy',
            roles: [{ title: { name: 'mid lane' } }],
          },
        ],
        'team-3': [
          {
            id: 'player-3',
            nickname: 'Bdd',
            roles: [{ name: 'mid' }],
          },
        ],
      },
      statesBySeriesId: {
        'series-1': {
          valid: true,
          started: true,
          finished: true,
          teams: [
            {
              id: 'team-1',
              won: true,
              score: 2,
            },
            {
              id: 'team-2',
              won: false,
              score: 1,
            },
          ],
        },
        'series-2': {
          valid: true,
          started: false,
          finished: false,
          teams: [
            {
              id: 'team-1',
              won: false,
              score: 0,
            },
            {
              id: 'team-3',
              won: false,
              score: 0,
            },
          ],
        },
        'series-3': null,
      },
    };

    const snapshot = parser.parseSnapshot(payload);

    expect(snapshot.teams).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          externalId: 'team-1',
          name: 'T1',
          shortName: 'T1',
          wins: 1,
          losses: 0,
          setWins: 2,
          setLosses: 1,
          rank: 1,
        }),
        expect.objectContaining({
          externalId: 'team-2',
          name: 'Gen.G Esports',
          shortName: 'GE',
          wins: 0,
          losses: 1,
          setWins: 1,
          setLosses: 2,
          rank: 3,
        }),
        expect.objectContaining({
          externalId: 'team-3',
          name: 'KT Rolster',
          shortName: 'KR',
          wins: 0,
          losses: 0,
          setWins: 0,
          setLosses: 0,
          rank: 2,
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
        }),
        expect.objectContaining({
          externalId: 'player-2',
          name: 'Chovy',
          teamExternalId: 'team-2',
          position: PlayerPosition.MID,
        }),
      ]),
    );

    expect(snapshot.matches).toEqual([
      expect.objectContaining({
        externalId: 'series-1',
        split: 'LCK Spring 2026',
        stage: 'LCK Spring 2026',
        homeTeamExternalId: 'team-1',
        awayTeamExternalId: 'team-2',
        homeScore: 2,
        awayScore: 1,
        winnerTeamExternalId: 'team-1',
        status: MatchStatus.COMPLETED,
      }),
      expect.objectContaining({
        externalId: 'series-2',
        homeTeamExternalId: 'team-1',
        awayTeamExternalId: 'team-3',
        homeScore: 0,
        awayScore: 0,
        winnerTeamExternalId: null,
        status: MatchStatus.SCHEDULED,
      }),
    ]);
  });
});
