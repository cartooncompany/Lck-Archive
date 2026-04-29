import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { LckMapper } from '../mapper/lck.mapper';
import { LckSnapshotService } from '../services/lck-snapshot.service';

@Injectable()
export class LckSyncJob {
  private readonly logger = new Logger(LckSyncJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly lckSnapshotService: LckSnapshotService,
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
      const parsedSnapshot = await this.lckSnapshotService.fetchSnapshot();
      const teamIdMap = new Map<string, string>();
      const playerIdMap = new Map<string, string>();

      await this.prisma.$transaction(async (tx) => {
        for (const team of parsedSnapshot.teams) {
          const savedTeam = await tx.team.upsert(
            this.lckMapper.toTeamUpsertArgs(team),
          );
          teamIdMap.set(team.externalId, savedTeam.id);
        }

        for (const player of parsedSnapshot.players) {
          const savedPlayer = await tx.player.upsert(
            this.lckMapper.toPlayerUpsertArgs(
              player,
              player.teamExternalId
                ? teamIdMap.get(player.teamExternalId)
                : undefined,
            ),
          );
          playerIdMap.set(player.externalId, savedPlayer.id);
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

          const savedMatch = await tx.match.upsert(
            this.lckMapper.toMatchUpsertArgs(
              match,
              homeTeamId,
              awayTeamId,
              match.winnerTeamExternalId
                ? teamIdMap.get(match.winnerTeamExternalId)
                : undefined,
            ),
          );

          if (match.participants?.length) {
            const syncedPlayerIds: string[] = [];

            for (const participant of match.participants) {
              const playerId = playerIdMap.get(participant.playerExternalId);
              const teamId = teamIdMap.get(participant.teamExternalId);

              if (!playerId || !teamId) {
                this.logger.warn(
                  `Skip match participant sync because player or team is not resolved: match=${match.externalId}, player=${participant.playerExternalId}, team=${participant.teamExternalId}`,
                );
                continue;
              }

              syncedPlayerIds.push(playerId);

              await tx.matchPlayerParticipation.upsert({
                where: {
                  matchId_playerId: {
                    matchId: savedMatch.id,
                    playerId,
                  },
                },
                create: {
                  matchId: savedMatch.id,
                  playerId,
                  teamId,
                  role: participant.role ?? null,
                  isStarter: participant.isStarter ?? true,
                },
                update: {
                  teamId,
                  role: participant.role ?? null,
                  isStarter: participant.isStarter ?? true,
                },
              });
            }

            if (syncedPlayerIds.length > 0) {
              await tx.matchPlayerParticipation.deleteMany({
                where: {
                  matchId: savedMatch.id,
                  playerId: {
                    notIn: syncedPlayerIds,
                  },
                },
              });
            }
          }

          if (match.games?.length) {
            const syncedSequenceNumbers: number[] = [];

            for (const game of match.games) {
              const winnerTeamId = game.winnerTeamExternalId
                ? teamIdMap.get(game.winnerTeamExternalId)
                : undefined;

              syncedSequenceNumbers.push(game.sequenceNumber);

              const savedGame = await tx.matchGame.upsert({
                where: {
                  matchId_sequenceNumber: {
                    matchId: savedMatch.id,
                    sequenceNumber: game.sequenceNumber,
                  },
                },
                create: {
                  matchId: savedMatch.id,
                  externalId: game.externalId ?? null,
                  sequenceNumber: game.sequenceNumber,
                  startedAt: game.startedAt ? new Date(game.startedAt) : null,
                  duration: game.duration ?? null,
                  mapId: game.mapId ?? null,
                  mapName: game.mapName ?? null,
                  winnerTeamId: winnerTeamId ?? null,
                },
                update: {
                  externalId: game.externalId ?? null,
                  startedAt: game.startedAt ? new Date(game.startedAt) : null,
                  duration: game.duration ?? null,
                  mapId: game.mapId ?? null,
                  mapName: game.mapName ?? null,
                  winnerTeamId: winnerTeamId ?? null,
                },
              });

              if (game.playerStats?.length) {
                const syncedStatPlayerIds: string[] = [];

                for (const stat of game.playerStats) {
                  const playerId = playerIdMap.get(stat.playerExternalId);
                  const teamId = teamIdMap.get(stat.teamExternalId);

                  if (!playerId || !teamId) {
                    this.logger.warn(
                      `Skip game player stat sync because player or team is not resolved: match=${match.externalId}, game=${game.sequenceNumber}, player=${stat.playerExternalId}, team=${stat.teamExternalId}`,
                    );
                    continue;
                  }

                  syncedStatPlayerIds.push(playerId);

                  await tx.matchGamePlayerStat.upsert({
                    where: {
                      matchGameId_playerId: {
                        matchGameId: savedGame.id,
                        playerId,
                      },
                    },
                    create: {
                      matchGameId: savedGame.id,
                      playerId,
                      teamId,
                      role: stat.role ?? null,
                      participationStatus: stat.participationStatus ?? null,
                      characterId: stat.characterId ?? null,
                      characterName: stat.characterName ?? null,
                      kills: stat.kills ?? null,
                      deaths: stat.deaths ?? null,
                      assists: stat.assists ?? null,
                      totalMoneyEarned: stat.totalMoneyEarned ?? null,
                      damageDealt: stat.damageDealt ?? null,
                      damageTaken: stat.damageTaken ?? null,
                      visionScore: stat.visionScore ?? null,
                      kdaRatio: stat.kdaRatio ?? null,
                      killParticipation: stat.killParticipation ?? null,
                    },
                    update: {
                      teamId,
                      role: stat.role ?? null,
                      participationStatus: stat.participationStatus ?? null,
                      characterId: stat.characterId ?? null,
                      characterName: stat.characterName ?? null,
                      kills: stat.kills ?? null,
                      deaths: stat.deaths ?? null,
                      assists: stat.assists ?? null,
                      totalMoneyEarned: stat.totalMoneyEarned ?? null,
                      damageDealt: stat.damageDealt ?? null,
                      damageTaken: stat.damageTaken ?? null,
                      visionScore: stat.visionScore ?? null,
                      kdaRatio: stat.kdaRatio ?? null,
                      killParticipation: stat.killParticipation ?? null,
                    },
                  });
                }

                if (syncedStatPlayerIds.length > 0) {
                  await tx.matchGamePlayerStat.deleteMany({
                    where: {
                      matchGameId: savedGame.id,
                      playerId: {
                        notIn: syncedStatPlayerIds,
                      },
                    },
                  });
                }
              }

              await tx.matchDraftAction.deleteMany({
                where: {
                  matchGameId: savedGame.id,
                },
              });

              if (game.draftActions?.length) {
                await tx.matchDraftAction.createMany({
                  data: game.draftActions.map((action) => ({
                    matchGameId: savedGame.id,
                    externalId: action.externalId ?? null,
                    type: action.type,
                    sequenceNumber: action.sequenceNumber,
                    sequenceOrder: action.sequenceOrder ?? null,
                    drafterId: action.drafterId ?? null,
                    drafterType: action.drafterType ?? null,
                    draftableId: action.draftableId ?? null,
                    draftableType: action.draftableType ?? null,
                    draftableName: action.draftableName ?? null,
                  })),
                });
              }
            }

            if (syncedSequenceNumbers.length > 0) {
              await tx.matchGame.deleteMany({
                where: {
                  matchId: savedMatch.id,
                  sequenceNumber: {
                    notIn: syncedSequenceNumbers,
                  },
                },
              });
            }
          }
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
