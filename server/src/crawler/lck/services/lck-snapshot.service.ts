import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GridLckClient } from '../client/grid-lck.client';
import { LckApiClient } from '../client/lck-api.client';
import { LckParser } from '../parser/lck.parser';
import { RawLckSnapshotPayload } from '../types/lck-source.types';

type LckDataSource = 'auto' | 'grid' | 'lolesports';

@Injectable()
export class LckSnapshotService {
  private readonly logger = new Logger(LckSnapshotService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly lckApiClient: LckApiClient,
    private readonly lckParser: LckParser,
    private readonly gridLckClient: GridLckClient,
  ) {}

  async fetchSnapshot(): Promise<RawLckSnapshotPayload> {
    const configuredSource = this.getConfiguredSource();

    if (configuredSource === 'grid') {
      return this.gridLckClient.fetchSnapshot();
    }

    if (configuredSource === 'lolesports') {
      return this.fetchLolesportsSnapshot();
    }

    if (this.gridLckClient.hasApiKey()) {
      try {
        return await this.gridLckClient.fetchSnapshot();
      } catch (error) {
        const message =
          error instanceof Error ? error.message : 'Unknown GRID sync error';

        this.logger.warn(
          `GRID snapshot fetch failed, falling back to LoL Esports persisted endpoints: ${message}`,
        );
      }
    }

    return this.fetchLolesportsSnapshot();
  }

  private async fetchLolesportsSnapshot(): Promise<RawLckSnapshotPayload> {
    const snapshot = await this.lckApiClient.fetchSnapshot();
    return this.lckParser.parseSnapshot(snapshot);
  }

  private getConfiguredSource(): LckDataSource {
    const value = this.configService
      .get<string>('LCK_DATA_SOURCE')
      ?.trim()
      .toLowerCase();

    if (value === 'grid' || value === 'lolesports') {
      return value;
    }

    return 'auto';
  }
}
