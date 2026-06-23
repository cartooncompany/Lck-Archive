import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  try {
    const match = await prisma.match.findFirst({
      where: {
        homeTeam: { shortName: 'T1' },
        awayTeam: { shortName: 'GEN' },
      },
      include: {
        games: {
          include: {
            playerStats: {
              include: {
                player: true,
                team: true,
              }
            }
          },
          orderBy: {
            sequenceNumber: 'asc',
          }
        }
      },
      orderBy: {
        scheduledAt: 'desc',
      }
    });

    if (!match) {
      console.log('T1 vs GEN 매치를 찾을 수 없습니다.');
      return;
    }

    console.log(`=== 경기 상세: T1 ${match.homeScore} : ${match.awayScore} GEN ===`);
    for (const game of match.games) {
      console.log(`\n--- ${game.sequenceNumber}세트 (승리팀: ${game.winnerTeamId === match.homeTeamId ? 'T1' : 'GEN'}, 시간: ${game.duration}) ---`);
      
      const t1Stats = game.playerStats.filter(s => s.team.shortName === 'T1');
      const genStats = game.playerStats.filter(s => s.team.shortName === 'GEN');

      console.log('T1 라인업:');
      for (const s of t1Stats) {
        console.log(`  [${s.role}] ${s.player.name} - 챔피언: ${s.characterName}, KDA: ${s.kills}/${s.deaths}/${s.assists} (KP: ${Math.round((s.killParticipation || 0) * 100)}%), 골드: ${s.totalMoneyEarned}, 딜: ${s.damageDealt}`);
      }

      console.log('GEN 라인업:');
      for (const s of genStats) {
        console.log(`  [${s.role}] ${s.player.name} - 챔피언: ${s.characterName}, KDA: ${s.kills}/${s.deaths}/${s.assists} (KP: ${Math.round((s.killParticipation || 0) * 100)}%), 골드: ${s.totalMoneyEarned}, 딜: ${s.damageDealt}`);
      }
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
