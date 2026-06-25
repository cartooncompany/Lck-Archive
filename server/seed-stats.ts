import { PrismaClient, PlayerPosition, MatchStatus } from '@prisma/client';

const prisma = new PrismaClient();

// 한국인 유저에게 친숙한 공식 국문 챔피언 풀 정의 (역할군별 분리)
const POSITION_CHAMPIONS: Record<PlayerPosition, string[]> = {
  [PlayerPosition.TOP]: [
    '레넥톤', '아트록스', '잭스', '나르', '오른', '케넨', 
    '올라프', '그라가스', '제이스', '럼블', '크산테', '카밀'
  ],
  [PlayerPosition.JUNGLE]: [
    '리 신', '세주아니', '비에고', '니달리', '그레이브즈', '마오카이', 
    '엘리스', '신 짜오', '바이', '녹턴', '자반 4세'
  ],
  [PlayerPosition.MID]: [
    '아지르', '오리아나', '신드라', '아리', '빅터', '요네', 
    '사일러스', '탈리야', '라이즈', '코르키', '르블랑'
  ],
  [PlayerPosition.ADC]: [
    '카이사', '이즈리얼', '징크스', '아펠리오스', '제리', '바루스', 
    '루시안', '애쉬', '칼리스타', '세나', '진', '미스 포츈'
  ],
  [PlayerPosition.SUPPORT]: [
    '알리스타', '쓰레쉬', '룰루', '노틸러스', '라칸', '브라움', 
    '나미', '바드', '레오나', '카르마', '유미'
  ],
  [PlayerPosition.COACH]: ['아지르'],
  [PlayerPosition.SUBSTITUTE]: ['아지르'],
  [PlayerPosition.FLEX]: ['아지르']
};

// 밴픽용 예비 한글 챔피언 풀 (게임 챔피언과 겹치지 않는 밴 카드용)
const BAN_CHAMPIONS_POOL = [
  '니코', '갈리오', '룰루', '모르가나', '말파이트', '렝가', '블리츠크랭크', '뽀삐',
  '샤코', '신드라', '아칼리', '이블린', '일라오이', '조이', '직스', '초가스', '카사딘',
  '카타리나', '케일', '킨드레드', '타릭', '트린다미어', '피즈', '하이머딩거', '헤카림'
];

// 각 팀별 실제 유명 주전 스타 선수 목록 (동일 포지션 내 2군/후보 기용 방지)
const STAR_PLAYERS = new Set([
  // T1
  'Doran', 'Oner', 'Faker', 'Peyz', 'Keria',
  // Gen.G
  'Kiin', 'Canyon', 'Chovy', 'Ruler', 'Duro',
  // HLE
  'Zeus', 'Kanavi', 'Zeka', 'Gumayusi', 'Delight',
  // DK
  'Siwoo', 'Lucid', 'ShowMaker', 'Smash', 'Career',
  // KT
  'PerfecT', 'Cuzz', 'Bdd', 'Aiming', 'Effort',
  // NS
  'Kingen', 'Sponge', 'Scout', 'Diable', 'Lehends',
  // BFX
  'Clear', 'Raptor', 'VicLa', 'Taeyoon', 'Kellin',
  // BRO
  'Casting', 'GIDEON', 'Loki', 'Teddy', 'Namgung',
  // DRX (KRX)
  'Rich', 'Willer', 'Ucal', 'Jiwoo', 'Andil',
  // DNS (DN SOOPers)
  'DuDu', 'Pyosik', 'Clozer', 'deokdam', 'Life'
]);

function shuffleArray<T>(array: T[]): T[] {
  const copy = [...array];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function randomRange(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function distributeValue(total: number, weights: number[], noiseFactor = 0.0): number[] {
  // 각 가중치에 무작위 편차(noise)를 곱해 임시 가중치를 만듭니다.
  const randomizedWeights = weights.map(w => {
    if (noiseFactor <= 0) return w;
    const noise = 1.0 + (Math.random() - 0.5) * noiseFactor;
    return Math.max(0.1, w * noise);
  });

  const result = new Array(randomizedWeights.length).fill(0);
  let remaining = total;
  
  const totalWeight = randomizedWeights.reduce((sum, w) => sum + w, 0);
  for (let i = 0; i < randomizedWeights.length; i++) {
    const val = Math.floor((randomizedWeights[i] / totalWeight) * total);
    result[i] = val;
    remaining -= val;
  }
  
  while (remaining > 0) {
    const r = Math.random() * totalWeight;
    let accum = 0;
    for (let i = 0; i < randomizedWeights.length; i++) {
      accum += randomizedWeights[i];
      if (r <= accum) {
        result[i]++;
        remaining--;
        break;
      }
    }
  }
  
  return result;
}

interface PlayerBias {
  killMultiplier?: number;
  deathMultiplier?: number;
  assistMultiplier?: number;
  goldMultiplier?: number;
  damageMultiplier?: number;
  tankMultiplier?: number;
}

const PLAYER_BIASES: Record<string, PlayerBias> = {
  // T1
  'Faker': { killMultiplier: 1.05, assistMultiplier: 1.15, goldMultiplier: 1.02, damageMultiplier: 1.12 },
  'Doran': { tankMultiplier: 1.25, deathMultiplier: 1.15, goldMultiplier: 0.90 },
  'Oner': { killMultiplier: 1.10, assistMultiplier: 1.05, tankMultiplier: 1.15, goldMultiplier: 1.05 },
  'Peyz': { killMultiplier: 1.15, goldMultiplier: 1.08, damageMultiplier: 1.15, deathMultiplier: 0.85 },
  'Keria': { killMultiplier: 1.20, assistMultiplier: 1.15, goldMultiplier: 1.10, damageMultiplier: 1.30 },
  
  // Gen.G
  'Chovy': { goldMultiplier: 1.20, damageMultiplier: 1.22, killMultiplier: 1.12, deathMultiplier: 0.70 },
  'Kiin': { damageMultiplier: 1.08, tankMultiplier: 1.15, goldMultiplier: 1.05 },
  'Canyon': { killMultiplier: 1.15, damageMultiplier: 1.12, goldMultiplier: 1.08 },
  'Ruler': { killMultiplier: 1.18, goldMultiplier: 1.12, damageMultiplier: 1.16, deathMultiplier: 0.75 },
  'Duro': { assistMultiplier: 1.25, tankMultiplier: 1.15, goldMultiplier: 0.90 },

  // HLE
  'Zeus': { damageMultiplier: 1.18, killMultiplier: 1.10, tankMultiplier: 0.85, goldMultiplier: 1.08 },
  'Kanavi': { killMultiplier: 1.18, damageMultiplier: 1.15, goldMultiplier: 1.10 },
  'Zeka': { killMultiplier: 1.15, damageMultiplier: 1.16, goldMultiplier: 1.06 },
  'Gumayusi': { killMultiplier: 1.16, goldMultiplier: 1.06, damageMultiplier: 1.14, deathMultiplier: 0.78 },
  'Delight': { assistMultiplier: 1.35, tankMultiplier: 1.25, goldMultiplier: 0.82 },

  // DK
  'ShowMaker': { assistMultiplier: 1.12, damageMultiplier: 1.08, killMultiplier: 1.05 },
  'Lucid': { assistMultiplier: 1.08, tankMultiplier: 1.10 },
  'Siwoo': { tankMultiplier: 1.15, deathMultiplier: 1.12 },
  'Smash': { killMultiplier: 1.10, goldMultiplier: 1.05 },
  'Career': { assistMultiplier: 1.10 },

  // KT
  'Bdd': { damageMultiplier: 1.10, assistMultiplier: 1.08 },
  'Aiming': { killMultiplier: 1.18, goldMultiplier: 1.10, damageMultiplier: 1.16 },
  'Cuzz': { assistMultiplier: 1.10, tankMultiplier: 1.10 },
  'PerfecT': { tankMultiplier: 1.12 },
  'Effort': { assistMultiplier: 1.10, deathMultiplier: 1.20 },

  // NS
  'Scout': { killMultiplier: 1.10, damageMultiplier: 1.12, goldMultiplier: 1.05 },
  'Lehends': { assistMultiplier: 1.25, killMultiplier: 1.10, deathMultiplier: 1.15 },
  'Kingen': { tankMultiplier: 1.20, damageMultiplier: 1.05 },
  'Sponge': { tankMultiplier: 1.08 },
  'Diable': { killMultiplier: 1.05 },

  // DNS
  'Clozer': { killMultiplier: 1.12, damageMultiplier: 1.14, goldMultiplier: 1.04 },
  'Pyosik': { killMultiplier: 1.08, assistMultiplier: 1.08, tankMultiplier: 1.10 },
  'deokdam': { killMultiplier: 1.12, goldMultiplier: 1.06, damageMultiplier: 1.12 },
  'Life': { assistMultiplier: 1.15, tankMultiplier: 1.12 },
  'DuDu': { damageMultiplier: 1.06, tankMultiplier: 1.08 },
};

function getAdjustedWeights(
  baseWeights: number[],
  lineup: Record<PlayerPosition, any>,
  biasKey: keyof PlayerBias
): number[] {
  const positions: PlayerPosition[] = [
    PlayerPosition.TOP,
    PlayerPosition.JUNGLE,
    PlayerPosition.MID,
    PlayerPosition.ADC,
    PlayerPosition.SUPPORT
  ];

  return baseWeights.map((weight, idx) => {
    const pos = positions[idx];
    const player = lineup[pos];
    if (!player) return weight;

    const bias = PLAYER_BIASES[player.name];
    if (!bias) return weight;

    const multiplier = bias[biasKey] ?? 1.0;
    return weight * multiplier;
  });
}

function generateGameWinners(
  homeScore: number,
  awayScore: number,
  homeTeamId: string,
  awayTeamId: string,
): string[] {
  const gameWinners: string[] = [];
  const totalGames = homeScore + awayScore;

  if (totalGames === 0) {
    return [homeTeamId];
  }

  const isHomeWin = homeScore > awayScore;
  const winnerId = isHomeWin ? homeTeamId : awayTeamId;
  const loserId = isHomeWin ? awayTeamId : homeTeamId;

  const targetWins = Math.max(homeScore, awayScore);
  const loserWins = Math.min(homeScore, awayScore);

  if (targetWins <= 1) {
    let h = homeScore;
    let a = awayScore;
    for (let i = 0; i < totalGames; i++) {
      if (h > 0) {
        gameWinners.push(homeTeamId);
        h--;
      } else {
        gameWinners.push(awayTeamId);
        a--;
      }
    }
    return gameWinners;
  }

  if (loserWins === 0) {
    for (let i = 0; i < targetWins; i++) {
      gameWinners.push(winnerId);
    }
    return gameWinners;
  }

  const pool: string[] = [];
  for (let i = 0; i < targetWins - 1; i++) {
    pool.push(winnerId);
  }
  for (let i = 0; i < loserWins; i++) {
    pool.push(loserId);
  }

  const shuffledPool = shuffleArray(pool);
  gameWinners.push(...shuffledPool);
  gameWinners.push(winnerId);

  return gameWinners;
}

async function main() {
  console.log('=== LCK 스탯 Mock 데이터 한글화 및 밴픽 포함 정밀 Seeding 시작 ===');

  try {
    const matches = await prisma.match.findMany({
      where: {
        status: MatchStatus.COMPLETED,
      },
      include: {
        homeTeam: {
          include: { players: true },
        },
        awayTeam: {
          include: { players: true },
        },
      },
    });

    console.log(`대상 매치 수: ${matches.length}개`);

    console.log('기존 MatchGame 및 관련 데이터 삭제 중...');
    await prisma.matchGamePlayerStat.deleteMany({});
    await prisma.matchPlayerParticipation.deleteMany({});
    await prisma.matchDraftAction.deleteMany({});
    await prisma.matchGame.deleteMany({});
    console.log('삭제 완료.');

    let gameInsertCount = 0;
    let statInsertCount = 0;
    let partInsertCount = 0;
    let draftInsertCount = 0;

    const batchSize = 50;
    for (let i = 0; i < matches.length; i += batchSize) {
      const chunk = matches.slice(i, i + batchSize);
      console.log(`진행 상황: ${i}/${matches.length} 매치 처리 중...`);

      const gamesToCreate: any[] = [];
      const statsToCreate: any[] = [];
      const partsToCreate: any[] = [];
      const draftsToCreate: any[] = [];

      for (const match of chunk) {
        const homeScore = match.homeScore;
        const awayScore = match.awayScore;
        const totalGames = homeScore + awayScore === 0 ? 1 : homeScore + awayScore;

        const gameWinners = generateGameWinners(
          homeScore,
          awayScore,
          match.homeTeamId,
          match.awayTeamId,
        );

        const getStarLineup = (players: any[]) => {
          const lineup: Record<PlayerPosition, any> = {} as any;
          const positions: PlayerPosition[] = [
            PlayerPosition.TOP,
            PlayerPosition.JUNGLE,
            PlayerPosition.MID,
            PlayerPosition.ADC,
            PlayerPosition.SUPPORT
          ];

          for (const pos of positions) {
            const posPlayers = players.filter(p => p.position === pos);
            if (posPlayers.length > 0) {
              const star = posPlayers.find(p => STAR_PLAYERS.has(p.name));
              if (star) {
                lineup[pos] = star;
              } else {
                posPlayers.sort((a, b) => a.name.localeCompare(b.name));
                lineup[pos] = posPlayers[0];
              }
            } else {
              const unassigned = players.filter(p => !Object.values(lineup).includes(p));
              lineup[pos] = unassigned.length > 0 ? unassigned[0] : players[0];
            }
          }
          return lineup;
        };

        const homeLineup = getStarLineup(match.homeTeam.players);
        const awayLineup = getStarLineup(match.awayTeam.players);

        const allParticipants = [
          ...Object.values(homeLineup),
          ...Object.values(awayLineup)
        ].filter(p => p !== undefined);

        for (const p of allParticipants) {
          partsToCreate.push({
            matchId: match.id,
            playerId: p.id,
            teamId: p.teamId!,
            role: p.position,
            isStarter: true,
          });
        }

        for (let seq = 1; seq <= totalGames; seq++) {
          const gameId = `${match.id}-g${seq}`;
          const winnerTeamId = gameWinners[seq - 1];
          const durationMinutes = randomRange(26, 42);
          const durationSeconds = randomRange(10, 59);
          const durationStr = `${durationMinutes}:${durationSeconds}`;

          gamesToCreate.push({
            id: gameId,
            matchId: match.id,
            sequenceNumber: seq,
            winnerTeamId,
            mapName: 'Summoner\'s Rift',
            duration: durationStr,
            startedAt: new Date(match.scheduledAt.getTime() + seq * 3600000),
          });

          // 포지션별 챔피언 배정 (게임 내 중복 방지)
          const assignedChampions: Record<PlayerPosition, { home: string, away: string }> = {} as any;
          const positions: PlayerPosition[] = [
            PlayerPosition.TOP,
            PlayerPosition.JUNGLE,
            PlayerPosition.MID,
            PlayerPosition.ADC,
            PlayerPosition.SUPPORT
          ];

          positions.forEach(pos => {
            const champs = shuffleArray(POSITION_CHAMPIONS[pos]);
            assignedChampions[pos] = {
              home: champs[0],
              away: champs[1]
            };
          });

          const isHomeWin = winnerTeamId === match.homeTeamId;
          const homeKillsTotal = isHomeWin ? randomRange(13, 26) : randomRange(3, 12);
          const awayKillsTotal = isHomeWin ? randomRange(3, 12) : randomRange(13, 26);

          const homeKillWeights = getAdjustedWeights([20, 15, 28, 32, 5], homeLineup, 'killMultiplier');
          const awayKillWeights = getAdjustedWeights([20, 15, 28, 32, 5], awayLineup, 'killMultiplier');

          const homeDeathWeights = getAdjustedWeights([22, 24, 18, 16, 20], homeLineup, 'deathMultiplier');
          const awayDeathWeights = getAdjustedWeights([22, 24, 18, 16, 20], awayLineup, 'deathMultiplier');

          const homeAssistWeights = getAdjustedWeights([15, 25, 20, 12, 38], homeLineup, 'assistMultiplier');
          const awayAssistWeights = getAdjustedWeights([15, 25, 20, 12, 38], awayLineup, 'assistMultiplier');

          const homeKills = distributeValue(homeKillsTotal, homeKillWeights, 0.25);
          const awayDeaths = distributeValue(homeKillsTotal, awayDeathWeights, 0.20);

          const awayKills = distributeValue(awayKillsTotal, awayKillWeights, 0.25);
          const homeDeaths = distributeValue(awayKillsTotal, homeDeathWeights, 0.20);

          const homeAssistsTotal = Math.round(homeKillsTotal * randomRange(17, 24) / 10);
          const awayAssistsTotal = Math.round(awayKillsTotal * randomRange(17, 24) / 10);

          const homeAssists = distributeValue(homeAssistsTotal, homeAssistWeights, 0.15);
          const awayAssists = distributeValue(awayAssistsTotal, awayAssistWeights, 0.15);

          const baseHomeGold = durationMinutes * 1600;
          const baseAwayGold = durationMinutes * 1600;
          const homeGoldTotal = Math.round(isHomeWin ? baseHomeGold * 1.12 : baseHomeGold * 0.9);
          const awayGoldTotal = Math.round(!isHomeWin ? baseAwayGold * 1.12 : baseAwayGold * 0.9);

          const homeGoldWeights = getAdjustedWeights([22, 17, 23, 27, 11], homeLineup, 'goldMultiplier');
          const awayGoldWeights = getAdjustedWeights([22, 17, 23, 27, 11], awayLineup, 'goldMultiplier');
          const homeGold = distributeValue(homeGoldTotal, homeGoldWeights, 0.10);
          const awayGold = distributeValue(awayGoldTotal, awayGoldWeights, 0.10);

          const damageTotal = durationMinutes * 3200;
          const homeDamageWeights = getAdjustedWeights([22, 12, 32, 29, 5], homeLineup, 'damageMultiplier');
          const awayDamageWeights = getAdjustedWeights([22, 12, 32, 29, 5], awayLineup, 'damageMultiplier');
          const homeDamage = distributeValue(damageTotal, homeDamageWeights, 0.20);
          const awayDamage = distributeValue(damageTotal, awayDamageWeights, 0.20);

          const tankTotal = durationMinutes * 3400;
          const homeTankWeights = getAdjustedWeights([32, 28, 14, 12, 14], homeLineup, 'tankMultiplier');
          const awayTankWeights = getAdjustedWeights([32, 28, 14, 12, 14], awayLineup, 'tankMultiplier');
          const homeTank = distributeValue(tankTotal, homeTankWeights, 0.15);
          const awayTank = distributeValue(tankTotal, awayTankWeights, 0.15);

          // Home 팀 스탯 생성 및 픽 챔피언 기억
          positions.forEach((pos, idx) => {
            const player = homeLineup[pos];
            if (!player) return;

            const kills = homeKills[idx];
            const deaths = homeDeaths[idx];
            const assists = homeAssists[idx];
            const kdaRatio = deaths > 0 ? parseFloat(((kills + assists) / deaths).toFixed(2)) : (kills + assists);
            const kp = homeKillsTotal > 0 ? parseFloat(((kills + assists) / homeKillsTotal).toFixed(2)) : 0;
            const vs = parseFloat((durationMinutes * (pos === PlayerPosition.SUPPORT ? 1.8 : pos === PlayerPosition.JUNGLE ? 0.9 : 0.4) + randomRange(0, 3)).toFixed(1));

            statsToCreate.push({
              matchGameId: gameId,
              playerId: player.id,
              teamId: match.homeTeamId,
              role: pos,
              characterName: assignedChampions[pos].home,
              kills,
              deaths,
              assists,
              totalMoneyEarned: homeGold[idx],
              damageDealt: homeDamage[idx],
              damageTaken: homeTank[idx],
              visionScore: vs,
              kdaRatio,
              killParticipation: kp,
              participationStatus: 'COMPLETED',
            });
          });

          // Away 팀 스탯 생성 및 픽 챔피언 기억
          positions.forEach((pos, idx) => {
            const player = awayLineup[pos];
            if (!player) return;

            const kills = awayKills[idx];
            const deaths = awayDeaths[idx];
            const assists = awayAssists[idx];
            const kdaRatio = deaths > 0 ? parseFloat(((kills + assists) / deaths).toFixed(2)) : (kills + assists);
            const kp = awayKillsTotal > 0 ? parseFloat(((kills + assists) / awayKillsTotal).toFixed(2)) : 0;
            const vs = parseFloat((durationMinutes * (pos === PlayerPosition.SUPPORT ? 1.8 : pos === PlayerPosition.JUNGLE ? 0.9 : 0.4) + randomRange(0, 3)).toFixed(1));

            statsToCreate.push({
              matchGameId: gameId,
              playerId: player.id,
              teamId: match.awayTeamId,
              role: pos,
              characterName: assignedChampions[pos].away,
              kills,
              deaths,
              assists,
              totalMoneyEarned: awayGold[idx],
              damageDealt: awayDamage[idx],
              damageTaken: awayTank[idx],
              visionScore: vs,
              kdaRatio,
              killParticipation: kp,
              participationStatus: 'COMPLETED',
            });
          });

          // 5. 밴픽 드래프트 액션(MatchDraftAction) 시뮬레이션 데이터 구축
          // 밴 10개 추출 (게임 내 사용 챔피언과 겹치지 않는 예비 풀 사용)
          const banChamps = shuffleArray(BAN_CHAMPIONS_POOL).slice(0, 10);
          
          // 드래프트 순서대로 BAN / PICK 빌드
          // 순서 1~6: 1단계 밴 (블루/레드 교차)
          // 순서 7~12: 1단계 픽 (블루/레드 교차)
          // 순서 13~16: 2단계 밴 (블루/레드 교차)
          // 순서 17~20: 2단계 픽 (레드/블루 교차)
          const draftOrders = [
            { seq: 1, type: 'BAN', isHome: true, champ: banChamps[0] },
            { seq: 2, type: 'BAN', isHome: false, champ: banChamps[1] },
            { seq: 3, type: 'BAN', isHome: true, champ: banChamps[2] },
            { seq: 4, type: 'BAN', isHome: false, champ: banChamps[3] },
            { seq: 5, type: 'BAN', isHome: true, champ: banChamps[4] },
            { seq: 6, type: 'BAN', isHome: false, champ: banChamps[5] },
            
            { seq: 7, type: 'PICK', isHome: true, champ: assignedChampions[PlayerPosition.MID].home },
            { seq: 8, type: 'PICK', isHome: false, champ: assignedChampions[PlayerPosition.MID].away },
            { seq: 9, type: 'PICK', isHome: false, champ: assignedChampions[PlayerPosition.JUNGLE].away },
            { seq: 10, type: 'PICK', isHome: true, champ: assignedChampions[PlayerPosition.JUNGLE].home },
            { seq: 11, type: 'PICK', isHome: true, champ: assignedChampions[PlayerPosition.ADC].home },
            { seq: 12, type: 'PICK', isHome: false, champ: assignedChampions[PlayerPosition.ADC].away },
            
            { seq: 13, type: 'BAN', isHome: false, champ: banChamps[6] },
            { seq: 14, type: 'BAN', isHome: true, champ: banChamps[7] },
            { seq: 15, type: 'BAN', isHome: false, champ: banChamps[8] },
            { seq: 16, type: 'BAN', isHome: true, champ: banChamps[9] },
            
            { seq: 17, type: 'PICK', isHome: false, champ: assignedChampions[PlayerPosition.TOP].away },
            { seq: 18, type: 'PICK', isHome: true, champ: assignedChampions[PlayerPosition.TOP].home },
            { seq: 19, type: 'PICK', isHome: false, champ: assignedChampions[PlayerPosition.SUPPORT].away },
            { seq: 20, type: 'PICK', isHome: true, champ: assignedChampions[PlayerPosition.SUPPORT].home },
          ];

          draftOrders.forEach(order => {
            draftsToCreate.push({
              matchGameId: gameId,
              type: order.type,
              sequenceNumber: `${order.seq}`,
              sequenceOrder: order.seq,
              drafterId: order.isHome ? match.homeTeamId : match.awayTeamId,
              drafterType: 'TEAM',
              draftableType: 'CHAMPION',
              draftableName: order.champ,
            });
          });
        }
      }

      await prisma.matchGame.createMany({ data: gamesToCreate });
      await prisma.matchPlayerParticipation.createMany({ data: partsToCreate });
      await prisma.matchGamePlayerStat.createMany({ data: statsToCreate });
      await prisma.matchDraftAction.createMany({ data: draftsToCreate });

      gameInsertCount += gamesToCreate.length;
      partInsertCount += partsToCreate.length;
      statInsertCount += statsToCreate.length;
      draftInsertCount += draftsToCreate.length;
    }

    console.log('\n=== 정밀 Seeding 완료 ===');
    console.log(`생성된 MatchGames: ${gameInsertCount}개`);
    console.log(`생성된 MatchPlayerParticipations: ${partInsertCount}개`);
    console.log(`생성된 MatchGamePlayerStats: ${statInsertCount}개`);
    console.log(`생성된 MatchDraftActions: ${draftInsertCount}개`);

  } catch (err) {
    console.error('정밀 Seeding 중 에러 발생:', err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
