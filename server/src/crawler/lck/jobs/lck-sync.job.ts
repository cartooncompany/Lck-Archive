import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CacheInvalidatorService } from '../../../common/cache/cache-invalidator.service';
import { CacheNamespace } from '../../../common/cache/cache-namespaces';
import { PrismaService } from '../../../database/prisma.service';
import { LckSnapshotService } from '../services/lck-snapshot.service';
import { LckSyncPersisterService } from '../services/lck-sync-persister.service';

const DEFAULT_LCK_LIVE_REFRESH_INTERVAL_MS = 5 * 60 * 1000;

@Injectable()
export class LckSyncJob {
  private readonly logger = new Logger(LckSyncJob.name);
  private runningSync?: Promise<{
    teams: number;
    players: number;
    matches: number;
  }>;

  constructor(
    private readonly prisma: PrismaService,
    private readonly lckSnapshotService: LckSnapshotService,
    private readonly lckSyncPersister: LckSyncPersisterService,
    private readonly configService: ConfigService,
    private readonly cache: CacheInvalidatorService,
  ) {}

  async sync(): Promise<{ teams: number; players: number; matches: number }> {
    if (this.runningSync) {
      return this.runningSync;
    }

    this.runningSync = this.runSync().finally(() => {
      this.runningSync = undefined;
    });

    return this.runningSync;
  }

  async syncIfStale(): Promise<void> {
    if (!(await this.shouldRefresh())) {
      return;
    }

    try {
      await this.sync();
    } catch (error) {
      if (await this.hasMinimumSyncedData()) {
        const message =
          error instanceof Error ? error.message : 'Unknown sync error';
        this.logger.warn(
          `LCK live refresh failed. Serving existing cached data: ${message}`,
        );
        return;
      }

      throw error;
    }
  }

  private async runSync(): Promise<{
    teams: number;
    players: number;
    matches: number;
  }> {
    const jobStartTime = Date.now();
    const log = await this.prisma.syncJobLog.create({
      data: {
        jobName: 'lck-sync',
        status: 'RUNNING',
      },
    });

    try {
      this.logger.log('Starting snapshot fetch from source...');
      const parsedSnapshot = await this.lckSnapshotService.fetchSnapshot();

      this.logger.log('Starting data persistence mapping...');

      // 1. Teams 저장
      const teamIdMap = await this.lckSyncPersister.persistTeams(
        parsedSnapshot.teams,
      );

      // 2. Players 저장
      const playerIdMap = await this.lckSyncPersister.persistPlayers(
        parsedSnapshot.players,
        teamIdMap,
      );

      // 3. Matches 저장
      const { syncedMatches } = await this.lckSyncPersister.persistMatches(
        parsedSnapshot.matches,
        teamIdMap,
        playerIdMap,
      );

      const recordsCount =
        parsedSnapshot.teams.length +
        parsedSnapshot.players.length +
        parsedSnapshot.matches.length;

      const elapsed = Date.now() - jobStartTime;
      this.logger.log(
        `LCK sync job orchestrator completed successfully. Elapsed=${elapsed}ms`,
      );

      await this.prisma.syncJobLog.update({
        where: { id: log.id },
        data: {
          status: 'SUCCESS',
          finishedAt: new Date(),
          recordsCount,
        },
      });

      // 동기화로 데이터가 갱신되었으므로 관련 캐시를 무효화한다.
      await this.cache.invalidate(
        CacheNamespace.TEAMS,
        CacheNamespace.PLAYERS,
        CacheNamespace.MATCHES,
      );

      return {
        teams: parsedSnapshot.teams.length,
        players: parsedSnapshot.players.length,
        matches: syncedMatches,
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown sync error';

      this.logger.error(`LCK sync job orchestrator failed: ${message}`);

      await this.prisma.syncJobLog.update({
        where: { id: log.id },
        data: {
          status: 'FAILED',
          message,
          finishedAt: new Date(),
        },
      });

      throw error;
    }
  }

  private async shouldRefresh(): Promise<boolean> {
    const [teamCount, playerCount, matchCount, latestSuccess] =
      await Promise.all([
        this.prisma.team.count(),
        this.prisma.player.count(),
        this.prisma.match.count(),
        this.prisma.syncJobLog.findFirst({
          where: {
            jobName: 'lck-sync',
            status: 'SUCCESS',
          },
          orderBy: {
            startedAt: 'desc',
          },
          select: {
            startedAt: true,
            finishedAt: true,
          },
        }),
      ]);

    if (teamCount === 0 || playerCount === 0 || matchCount === 0) {
      return true;
    }

    const refreshIntervalMs = this.parseNonNegativeInt(
      this.configService.get<string>('LCK_LIVE_REFRESH_INTERVAL_MS'),
      DEFAULT_LCK_LIVE_REFRESH_INTERVAL_MS,
    );

    if (refreshIntervalMs === 0) {
      return false;
    }

    const refreshedAt = latestSuccess?.finishedAt ?? latestSuccess?.startedAt;
    if (!refreshedAt) {
      return true;
    }

    return Date.now() - refreshedAt.getTime() > refreshIntervalMs;
  }

  private async hasMinimumSyncedData(): Promise<boolean> {
    const [teamCount, playerCount, matchCount] = await Promise.all([
      this.prisma.team.count(),
      this.prisma.player.count(),
      this.prisma.match.count(),
    ]);

    return teamCount > 0 && playerCount > 0 && matchCount > 0;
  }

  private parseNonNegativeInt(
    value: string | undefined,
    fallback: number,
  ): number {
    const parsed = Number(value);
    return Number.isInteger(parsed) && parsed >= 0 ? parsed : fallback;
  }
}
