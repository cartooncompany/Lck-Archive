import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('=== Teams & Players ===');
    const teams = await prisma.team.findMany({
      include: {
        players: {
          select: {
            name: true,
            position: true,
          }
        }
      }
    });

    for (const team of teams) {
      console.log(`\n팀: ${team.name} (${team.shortName}) - 승: ${team.wins}, 패: ${team.losses}`);
      const playersStr = team.players.map(p => `${p.name}(${p.position})`).join(', ');
      console.log(`선수들: ${playersStr}`);
    }

    console.log('\n=== Recent 5 Matches ===');
    const matches = await prisma.match.findMany({
      include: {
        homeTeam: true,
        awayTeam: true,
        winnerTeam: true,
      },
      orderBy: {
        scheduledAt: 'desc',
      },
      take: 5,
    });

    for (const m of matches) {
      console.log(`[${m.scheduledAt.toISOString()}] ${m.homeTeam.shortName} ${m.homeScore} : ${m.awayScore} ${m.awayTeam.shortName} (승자: ${m.winnerTeam?.shortName ?? '없음'}) status: ${m.status}`);
    }

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
