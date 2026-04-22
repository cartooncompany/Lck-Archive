import { ConfigService } from '@nestjs/config';
import { GridLckClient } from '../client/grid-lck.client';
import { LckApiClient } from '../client/lck-api.client';
import { LckParser } from '../parser/lck.parser';
import { LckSnapshotService } from './lck-snapshot.service';
import {
  LolesportsSnapshotPayload,
  RawLckSnapshotPayload,
} from '../types/lck-source.types';

describe('LckSnapshotService', () => {
  const parsedSnapshot: RawLckSnapshotPayload = {
    teams: [],
    players: [],
    matches: [],
  };

  const lolesportsSnapshot: LolesportsSnapshotPayload = {
    standings: [],
    scheduleEvents: [],
    teams: [],
  };

  it('uses GRID when the source is explicitly configured', async () => {
    const service = new LckSnapshotService(
      new ConfigService({
        LCK_DATA_SOURCE: 'grid',
      }),
      {
        fetchSnapshot: jest.fn(),
      } as unknown as LckApiClient,
      {
        parseSnapshot: jest.fn(),
      } as unknown as LckParser,
      {
        hasApiKey: jest.fn().mockReturnValue(true),
        fetchSnapshot: jest.fn().mockResolvedValue(parsedSnapshot),
      } as unknown as GridLckClient,
    );

    await expect(service.fetchSnapshot()).resolves.toBe(parsedSnapshot);
  });

  it('falls back to LoL Esports when GRID fails in auto mode', async () => {
    const lckApiClient = {
      fetchSnapshot: jest.fn().mockResolvedValue(lolesportsSnapshot),
    } as unknown as LckApiClient;
    const lckParser = {
      parseSnapshot: jest.fn().mockReturnValue(parsedSnapshot),
    } as unknown as LckParser;
    const gridClient = {
      hasApiKey: jest.fn().mockReturnValue(true),
      fetchSnapshot: jest.fn().mockRejectedValue(new Error('permission denied')),
    } as unknown as GridLckClient;
    const service = new LckSnapshotService(
      new ConfigService({}),
      lckApiClient,
      lckParser,
      gridClient,
    );

    await expect(service.fetchSnapshot()).resolves.toBe(parsedSnapshot);
    expect(lckApiClient.fetchSnapshot).toHaveBeenCalledTimes(1);
    expect(lckParser.parseSnapshot).toHaveBeenCalledWith(lolesportsSnapshot);
  });

  it('uses LoL Esports when the source is explicitly configured', async () => {
    const lckApiClient = {
      fetchSnapshot: jest.fn().mockResolvedValue(lolesportsSnapshot),
    } as unknown as LckApiClient;
    const lckParser = {
      parseSnapshot: jest.fn().mockReturnValue(parsedSnapshot),
    } as unknown as LckParser;
    const gridClient = {
      hasApiKey: jest.fn().mockReturnValue(true),
      fetchSnapshot: jest.fn(),
    } as unknown as GridLckClient;
    const service = new LckSnapshotService(
      new ConfigService({
        LCK_DATA_SOURCE: 'lolesports',
      }),
      lckApiClient,
      lckParser,
      gridClient,
    );

    await expect(service.fetchSnapshot()).resolves.toBe(parsedSnapshot);
    expect(gridClient.fetchSnapshot).not.toHaveBeenCalled();
    expect(lckApiClient.fetchSnapshot).toHaveBeenCalledTimes(1);
  });
});
