import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { LckMapper } from '../mapper/lck.mapper';
import { RawLckTeamPayload, RawLckPlayerPayload, RawLckMatchPayload } from '../types/lck-source.types';

@Injectable()
export class LckSyncPersisterService {
  private readonly logger = new Logger(LckSyncPersisterService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly lckMapper: LckMapper,
  ) {}

  async persistTeams(teams: RawLckTeamPayload[]): Promise<Map<string, string>> {
    const teamIdMap = new Map<string, string>();
    const startTime = Date.now();

    await this.prisma.$transaction(async (tx) => {
      for (const team of teams) {
        const savedTeam = await tx.team.upsert(
          this.lckMapper.toTeamUpsertArgs(team),
        );
        teamIdMap.set(team.externalId, savedTeam.id);
      }
    });

    const elapsed = Date.now() - startTime;
    this.logger.log(`Teams persistence completed. Count=${teams.length}, Time=${elapsed}ms`);
    return teamIdMap;
  }

  async persistPlayers(
    players: RawLckPlayerPayload[],
    teamIdMap: Map<string, string>,
  ): Promise<Map<string, string>> {
    const playerIdMap = new Map<string, string>();
    const startTime = Date.now();

    await this.prisma.$transaction(async (tx) => {
      for (const player of players) {
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
    });

    const elapsed = Date.now() - startTime;
    this.logger.log(`Players persistence completed. Count=${players.length}, Time=${elapsed}ms`);
    return playerIdMap;
  }

  async persistMatches(
    matches: RawLckMatchPayload[],
    teamIdMap: Map<string, string>,
    playerIdMap: Map<string, string>,
  ): Promise<{ syncedMatches: number; skippedMatches: number }> {
    const startTime = Date.now();

    // 1. 기존 완료된 경기 상태 캐시 조회 (Diffing 최적화)
    const existingMatches = await this.prisma.match.findMany({
      select: {
        externalId: true,
        status: true,
      },
    });
    const existingMatchMap = new Map<string, string>();
    for (const m of existingMatches) {
      existingMatchMap.set(m.externalId, m.status);
    }

    let skippedMatches = 0;
    let syncedMatches = 0;

    // 2. Matches 동기화 (경기별 격리 트랜잭션 실행)
    for (const match of matches) {
      const homeTeamId = teamIdMap.get(match.homeTeamExternalId);
      const awayTeamId = teamIdMap.get(match.awayTeamExternalId);

      if (!homeTeamId || !awayTeamId) {
        this.logger.warn(
          `Skip match sync because teams are not resolved: ${match.externalId}`,
        );
        continue;
      }

      // Diffing Check: 이미 COMPLETED로 완결된 경기는 API에서 동기화할 필요가 없으므로 생략
      const existingStatus = existingMatchMap.get(match.externalId);
      if (existingStatus === 'COMPLETED' && match.status === 'COMPLETED') {
        skippedMatches++;
        continue;
      }

      const matchStartTime = Date.now();
      try {
        await this.prisma.$transaction(async (tx) => {
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
        });

        syncedMatches++;
        this.logger.debug(`Match synced in transaction: id=${match.externalId}, elapsed=${Date.now() - matchStartTime}ms`);
      } catch (error) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        this.logger.error(`Match transaction failed: match=${match.externalId}, error=${message}`);
      }
    }

    const elapsed = Date.now() - startTime;
    this.logger.log(`Matches persistence completed. Synced=${syncedMatches}, Skipped=${skippedMatches}, Time=${elapsed}ms`);
    return { syncedMatches, skippedMatches };
  }
}
