import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../database/prisma.service';
import { LckMapper } from '../mapper/lck.mapper';
import {
  RawLckTeamPayload,
  RawLckPlayerPayload,
  RawLckMatchPayload,
} from '../types/lck-source.types';

const EXTERNAL_SOURCE = 'LCK';

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

    if (teams.length === 0) {
      return teamIdMap;
    }

    await this.prisma.$transaction(async (tx) => {
      // 1. 기존 레코드를 한 번에 조회 (외부 ID -> 현재 저장된 데이터)
      const externalIds = teams.map((team) => team.externalId);
      const existing = await tx.team.findMany({
        where: {
          externalSource: EXTERNAL_SOURCE,
          externalId: { in: externalIds },
        },
      });
      const existingByExternalId = new Map(
        existing.map((row) => [row.externalId, row]),
      );

      // 2. 신규 / 변경 분리
      const toCreate: Prisma.TeamCreateManyInput[] = [];
      const toUpdate: Array<{ id: string; data: Prisma.TeamCreateManyInput }> =
        [];

      for (const team of teams) {
        const data = this.lckMapper.toTeamData(team);
        const current = existingByExternalId.get(team.externalId);

        if (!current) {
          toCreate.push(data);
        } else {
          teamIdMap.set(team.externalId, current.id);
          if (this.isDirty(current, data)) {
            toUpdate.push({ id: current.id, data });
          }
        }
      }

      // 3. 신규는 일괄 삽입
      if (toCreate.length > 0) {
        await tx.team.createMany({ data: toCreate });
      }

      // 4. 변경된 기존 레코드만 업데이트
      await Promise.all(
        toUpdate.map((item) =>
          tx.team.update({ where: { id: item.id }, data: item.data }),
        ),
      );

      // 5. 신규 삽입분의 id를 매핑에 채운다.
      if (toCreate.length > 0) {
        const created = await tx.team.findMany({
          where: {
            externalSource: EXTERNAL_SOURCE,
            externalId: { in: toCreate.map((c) => c.externalId) },
          },
          select: { id: true, externalId: true },
        });
        for (const row of created) {
          teamIdMap.set(row.externalId, row.id);
        }
      }
    });

    const elapsed = Date.now() - startTime;
    this.logger.log(
      `Teams persistence completed. Count=${teams.length}, Time=${elapsed}ms`,
    );
    return teamIdMap;
  }

  async persistPlayers(
    players: RawLckPlayerPayload[],
    teamIdMap: Map<string, string>,
  ): Promise<Map<string, string>> {
    const playerIdMap = new Map<string, string>();
    const startTime = Date.now();

    if (players.length === 0) {
      return playerIdMap;
    }

    await this.prisma.$transaction(async (tx) => {
      const externalIds = players.map((player) => player.externalId);
      const existing = await tx.player.findMany({
        where: {
          externalSource: EXTERNAL_SOURCE,
          externalId: { in: externalIds },
        },
      });
      const existingByExternalId = new Map(
        existing.map((row) => [row.externalId, row]),
      );

      const toCreate: Prisma.PlayerCreateManyInput[] = [];
      const toUpdate: Array<{
        id: string;
        data: Prisma.PlayerCreateManyInput;
      }> = [];

      for (const player of players) {
        const data = this.lckMapper.toPlayerData(
          player,
          player.teamExternalId
            ? teamIdMap.get(player.teamExternalId)
            : undefined,
        );
        const current = existingByExternalId.get(player.externalId);

        if (!current) {
          toCreate.push(data);
        } else {
          playerIdMap.set(player.externalId, current.id);
          if (this.isDirty(current, data)) {
            toUpdate.push({ id: current.id, data });
          }
        }
      }

      if (toCreate.length > 0) {
        await tx.player.createMany({ data: toCreate });
      }

      await Promise.all(
        toUpdate.map((item) =>
          tx.player.update({ where: { id: item.id }, data: item.data }),
        ),
      );

      if (toCreate.length > 0) {
        const created = await tx.player.findMany({
          where: {
            externalSource: EXTERNAL_SOURCE,
            externalId: { in: toCreate.map((c) => c.externalId) },
          },
          select: { id: true, externalId: true },
        });
        for (const row of created) {
          playerIdMap.set(row.externalId, row.id);
        }
      }
    });

    const elapsed = Date.now() - startTime;
    this.logger.log(
      `Players persistence completed. Count=${players.length}, Time=${elapsed}ms`,
    );
    return playerIdMap;
  }

  /**
   * 새로 매핑한 데이터(`next`)가 기존 레코드(`current`)와 다른 필드가
   * 하나라도 있으면 true를 반환한다. 변경이 없으면 불필요한 UPDATE를 생략한다.
   * Date는 시각 비교, 그 외는 일치 비교한다.
   */
  private isDirty(
    current: Record<string, unknown>,
    next: Record<string, unknown>,
  ): boolean {
    for (const [key, nextValue] of Object.entries(next)) {
      const currentValue = current[key];

      if (nextValue instanceof Date || currentValue instanceof Date) {
        const nextTime =
          nextValue instanceof Date ? nextValue.getTime() : nextValue;
        const currentTime =
          currentValue instanceof Date ? currentValue.getTime() : currentValue;
        if (nextTime !== currentTime) {
          return true;
        }
        continue;
      }

      if (currentValue !== nextValue) {
        return true;
      }
    }
    return false;
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
        _count: {
          select: {
            games: true,
          },
        },
      },
    });
    const existingMatchMap = new Map<
      string,
      { status: string; gameCount: number }
    >();
    for (const m of existingMatches) {
      existingMatchMap.set(m.externalId, {
        status: m.status,
        gameCount: m._count.games,
      });
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

      // Diffing Check: 이미 COMPLETED로 완결된 경기이고 세트 데이터까지 존재하면 동기화 생략
      const existing = existingMatchMap.get(match.externalId);
      if (
        existing &&
        existing.status === 'COMPLETED' &&
        match.status === 'COMPLETED' &&
        existing.gameCount > 0
      ) {
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
        this.logger.debug(
          `Match synced in transaction: id=${match.externalId}, elapsed=${Date.now() - matchStartTime}ms`,
        );
      } catch (error) {
        const message =
          error instanceof Error ? error.message : 'Unknown error';
        this.logger.error(
          `Match transaction failed: match=${match.externalId}, error=${message}`,
        );
      }
    }

    const elapsed = Date.now() - startTime;
    this.logger.log(
      `Matches persistence completed. Synced=${syncedMatches}, Skipped=${skippedMatches}, Time=${elapsed}ms`,
    );
    return { syncedMatches, skippedMatches };
  }
}
