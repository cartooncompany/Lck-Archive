import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { LckApiClient } from '../client/lck-api.client';
import { LckMapper } from '../mapper/lck.mapper';
import { LckParser } from '../parser/lck.parser';

@Injectable()
export class LckSyncJob {
  private readonly logger = new Logger(LckSyncJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly lckApiClient: LckApiClient,
    private readonly lckParser: LckParser,
    private readonly lckMapper: LckMapper,
  ) {}

  async sync(): Promise<{ teams: number; players: number; matches: number }> {
    const log = await this.prisma.syncJobLog.create({
      data: {
        jobName: 'lck-sync',
        status: 'RUNNING',
      },
    });

    try {
      const rawSnapshot = await this.lckApiClient.fetchSnapshot();
      const parsedSnapshot = this.lckParser.parseSnapshot(rawSnapshot);
      const teamIdMap = new Map<string, string>();

      await this.prisma.$transaction(async (tx) => {
        for (const team of parsedSnapshot.teams) {
          const savedTeam = await tx.team.upsert(
            this.lckMapper.toTeamUpsertArgs(team),
          );
          teamIdMap.set(team.externalId, savedTeam.id);
        }

        for (const player of parsedSnapshot.players) {
          await tx.player.upsert(
            this.lckMapper.toPlayerUpsertArgs(
              player,
              player.teamExternalId
                ? teamIdMap.get(player.teamExternalId)
                : undefined,
            ),
          );
        }

        for (const match of parsedSnapshot.matches) {
          const homeTeamId = teamIdMap.get(match.homeTeamExternalId);
          const awayTeamId = teamIdMap.get(match.awayTeamExternalId);

          if (!homeTeamId || !awayTeamId) {
            this.logger.warn(
              `Skip match sync because teams are not resolved: ${match.externalId}`,
            );
            continue;
          }

          await tx.match.upsert(
            this.lckMapper.toMatchUpsertArgs(
              match,
              homeTeamId,
              awayTeamId,
              match.winnerTeamExternalId
                ? teamIdMap.get(match.winnerTeamExternalId)
                : undefined,
            ),
          );
        }
      });

      const recordsCount =
        parsedSnapshot.teams.length +
        parsedSnapshot.players.length +
        parsedSnapshot.matches.length;

      await this.prisma.syncJobLog.update({
        where: { id: log.id },
        data: {
          status: 'SUCCESS',
          finishedAt: new Date(),
          recordsCount,
        },
      });

      return {
        teams: parsedSnapshot.teams.length,
        players: parsedSnapshot.players.length,
        matches: parsedSnapshot.matches.length,
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown sync error';

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
}
