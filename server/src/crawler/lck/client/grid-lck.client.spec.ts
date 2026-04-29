import { ConfigService } from '@nestjs/config';
import { GridLckParser } from '../parser/grid-lck.parser';
import { GridLckClient } from './grid-lck.client';

describe('GridLckClient', () => {
  it('requests participant data in the series state query', () => {
    const client = createClient();
    const query = (
      client as unknown as {
        buildSeriesStateQuery(seriesId: string): string;
      }
    ).buildSeriesStateQuery('series-1');

    expect(query).toContain('seriesState(id: "series-1")');
    expect(query).toContain('teams {');
    expect(query).toContain('players {');
    expect(query).toContain('participationStatus');
    expect(query).toContain('games {');
    expect(query).toContain('character {');
    expect(query).toContain('roles {');
    expect(query).toContain('killAssistsGiven');
    expect(query).toContain('... on GamePlayerStateLol');
    expect(query).toContain('totalMoneyEarned');
    expect(query).toContain('visionScore');
    expect(query).toContain('draftActions');
  });

  it('includes GRID GraphQL error metadata in thrown errors', async () => {
    const client = createClient();
    const post = jest.fn().mockResolvedValue({
      data: {
        errors: [
          {
            message: 'Requester forbidden to make query',
            path: ['seriesState'],
            extensions: {
              code: 'DOWNSTREAM_SERVICE_ERROR',
              serviceName: 'gql-cd-internal-query',
              errorType: 'PERMISSION_DENIED',
              errorDetail: 'INVALID_ARGUMENT',
            },
          },
        ],
      },
    });

    (
      client as unknown as {
        axiosClient: { post: typeof post };
      }
    ).axiosClient = { post };

    await expect(
      (
        client as unknown as {
          executeGraphql<T>(url: string, query: string): Promise<T>;
        }
      ).executeGraphql('https://api.grid.gg/test', 'query Test { id }'),
    ).rejects.toThrow(
      'PERMISSION_DENIED: INVALID_ARGUMENT: DOWNSTREAM_SERVICE_ERROR: gql-cd-internal-query: path=seriesState: Requester forbidden to make query',
    );
  });
});

function createClient(): GridLckClient {
  return new GridLckClient(
    new ConfigService({
      GRID_API_KEY: 'test-api-key',
      GRID_REQUESTS_PER_MINUTE: '50',
    }),
    new GridLckParser(),
  );
}
