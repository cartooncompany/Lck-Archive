import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  try {
    const totalMatches = await prisma.match.count();
    const completedMatches = await prisma.match.count({
      where: { status: 'COMPLETED' },
    });
    const scheduledMatches = await prisma.match.count({
      where: { status: 'SCHEDULED' },
    });

    console.log(`총 매치 수: ${totalMatches}`);
    console.log(`완료된 매치: ${completedMatches}`);
    console.log(`예정된 매치: ${scheduledMatches}`);

    const teams = await prisma.team.findMany({
      include: {
        _count: {
          select: { players: true }
        }
      }
    });

    console.log('\n=== 팀별 선수 수 ===');
    for (const team of teams) {
      console.log(`${team.name} (${team.shortName}): ${team._count.players}명`);
    }

  } catch (error) {
    console.error('에러:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
