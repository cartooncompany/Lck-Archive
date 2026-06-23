import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, SchemaType } from '@google/generative-ai';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private readonly genAI?: GoogleGenerativeAI;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      this.logger.warn(
        'GEMINI_API_KEY가 설정되지 않았습니다. AI 요약 기능이 동작하지 않습니다.',
      );
    } else {
      this.genAI = new GoogleGenerativeAI(apiKey);
    }
  }

  /**
   * 경기 상세 데이터를 바탕으로 AI 요약 리포트를 생성합니다.
   * @param matchDetail Controller/Service로부터 전달받은 경기 상세 정보 DTO
   */
  async generateMatchSummary(matchDetail: any): Promise<string> {
    if (!this.genAI) {
      throw new Error(
        'Gemini API 키가 구성되지 않았습니다. .env 파일에 GEMINI_API_KEY를 설정해주세요.',
      );
    }

    const model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
    const prompt = this.buildMatchSummaryPrompt(matchDetail);

    try {
      this.logger.log(
        `Starting AI match summary generation for match: ${matchDetail.id}`,
      );
      const result = await this.generateWithRetry(model, prompt);
      const text = result.response.text();
      this.logger.log(
        `Successfully generated AI summary for match: ${matchDetail.id}`,
      );
      return text;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`AI match summary generation failed: ${message}`);
      throw error;
    }
  }

  /**
   * 경기 상세 데이터를 AI 입력 프롬프트로 가공합니다.
   */
  private buildMatchSummaryPrompt(match: any): string {
    const homeTeam = match.homeTeam.name;
    const awayTeam = match.awayTeam.name;
    const homeScore = match.score.home;
    const awayScore = match.score.away;
    const winner = match.winner ? match.winner.name : '결과 미정';

    let gamesContext = '';

    if (match.games && Array.isArray(match.games)) {
      match.games.forEach((game: any) => {
        const gameNum = game.sequenceNumber;
        const duration = game.duration || '알 수 없음';
        const gameWinner = game.winner ? game.winner.name : '알 수 없음';

        // 밴픽 정보 정리
        const bans: string[] = [];
        const picks: string[] = [];

        if (game.draftActions && Array.isArray(game.draftActions)) {
          game.draftActions.forEach((action: any) => {
            if (action.type === 'ban' && action.draftableName) {
              bans.push(action.draftableName);
            } else if (action.type === 'pick' && action.draftableName) {
              const teamSide = action.drafterType === 'home' ? 'Home' : 'Away';
              picks.push(`${teamSide}(${action.draftableName})`);
            }
          });
        }

        // 선수 스탯 정리
        let playerStatsText = '';
        if (game.playerStats && Array.isArray(game.playerStats)) {
          game.playerStats.forEach((stat: any) => {
            const teamShort = stat.team.shortName;
            const name = stat.playerName;
            const pos = stat.position;
            const champ = stat.championName || '알 수 없음';
            const kda = `${stat.kills}/${stat.deaths}/${stat.assists}`;
            const damage = stat.damageDealt
              ? stat.damageDealt.toLocaleString()
              : '0';
            const kp = stat.killParticipation
              ? `${(stat.killParticipation * 100).toFixed(0)}%`
              : '0%';

            playerStatsText += `- [${teamShort}] ${pos} ${name} (${champ}) | KDA: ${kda} | 딜량: ${damage} | 킬관여율: ${kp}\n`;
          });
        }

        gamesContext += `
### [세트 ${gameNum}]
- 경기 시간: ${duration}
- 세트 승리 팀: ${gameWinner}
- 밴 목록: ${bans.length > 0 ? bans.join(', ') : '없음'}
- 픽 목록: ${picks.length > 0 ? picks.join(', ') : '없음'}
- 선수 개인 기록 및 지표:
${playerStatsText || '선수 지표 기록 없음'}
`;
      });
    }

    return `당신은 LCK(LoL Champions Korea) e스포츠 전문 기자이자 데이터 분석가입니다.
제공된 경기 통계 데이터를 분석하여, 팬들에게 유익하고 흥미로운 **[AI 경기 분석 요약 리포트]**를 한글로 작성해 주세요.

## [경기 정보]
- 매치업: ${homeTeam} vs ${awayTeam}
- 경기 결과: ${homeTeam} ${homeScore} : ${awayScore} ${awayTeam} (최종 승리: ${winner})

## [세트별 데이터]
${gamesContext}

## [작성 가이드라인]
1. **톤앤매너**: e스포츠 전문 매체의 기사처럼 흥미진진하면서도 데이터(딜량, KDA, 밴픽 등)에 기반하여 전문적으로 분석해 주세요.
2. **세트 분석**: 각 세트별로 경기의 승부처가 된 장면이나 선수(MVP/POG급 활약을 한 선수), 밴픽의 강점을 분석해 주세요.
3. **종합 의미**: 이번 경기 결과가 두 팀의 행보(순위 싸움, 기세, 메타 적응 등)에 어떤 영향을 미치는지 총평을 작성해 주세요.
4. **출력 형식**: Markdown 문법을 사용해 가독성 높게 단락을 나누어 작성해 주세요. (h3, 목록태그 등을 적극 활용)
5. **언어**: 반드시 자연스러운 한국어로 작성해 주세요.
`;
  }

  /**
   * 선수 상세 데이터를 바탕으로 AI 분석 요약 리포트를 생성합니다.
   */
  async generatePlayerSummary(playerDetail: any): Promise<string> {
    if (!this.genAI) {
      throw new Error(
        'Gemini API 키가 구성되지 않았습니다. .env 파일에 GEMINI_API_KEY를 설정해주세요.',
      );
    }

    const model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
    const prompt = this.buildPlayerSummaryPrompt(playerDetail);

    try {
      this.logger.log(
        `Starting AI player summary generation for player: ${playerDetail.name}`,
      );
      const result = await this.generateWithRetry(model, prompt);
      const text = result.response.text();
      this.logger.log(
        `Successfully generated AI summary for player: ${playerDetail.name}`,
      );
      return text;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`AI player summary generation failed: ${message}`);
      throw error;
    }
  }

  private buildPlayerSummaryPrompt(player: any): string {
    const name = player.name;
    const realName = player.realName || '미상';
    const position = player.position;
    const teamName = player.team?.name || '소속 팀 미상';
    const nationality = player.nationality || '미상';
    
    const stats = player.stats;
    let statsContext = '시즌 기록 데이터가 없습니다.';
    if (stats && stats.gamesPlayed > 0) {
      statsContext = `
- 총 출전 세트 수: ${stats.gamesPlayed} 게임
- 평균 KDA: ${stats.avgKda}
- 통산 K / D / A 합계: ${stats.totalKills} 킬 / ${stats.totalDeaths} 데스 / ${stats.totalAssists} 어시스트
- 평균 K / D / A (세트당): ${stats.avgKills} / ${stats.avgDeaths} / ${stats.avgAssists}
`;
    }

    let appearancesContext = '';
    if (player.recentAppearances && Array.isArray(player.recentAppearances)) {
      player.recentAppearances.forEach((app: any, idx: number) => {
        appearancesContext += `${idx + 1}. vs ${app.opponent} | 결과: ${app.result} | 성적(K/D/A 및 챔피언): ${app.performance}\n`;
      });
    }

    return `당신은 LCK(LoL Champions Korea) e스포츠 전문 분석가이자 스카우터입니다.
제공된 선수의 프로필 및 시즌 통계 지표, 최근 경기 출전 기록 데이터를 바탕으로, 팬들과 분석가들에게 해당 선수의 현재 폼과 활약상을 소개하는 흥미롭고 유익한 **[AI 선수 분석 리포트]**를 한글로 작성해 주세요.

## [선수 정보]
- 선수명 (닉네임): ${name}
- 본명: ${realName}
- 포지션: ${position}
- 소속 팀: ${teamName}
- 국적: ${nationality}

## [시즌 평균 지표]
${statsContext}

## [최근 경기 출전 기록 (최근 5경기)]
${appearancesContext || '최근 경기 기록 없음'}

## [작성 가이드라인]
1. **톤앤매너**: e스포츠 전문 기자의 스카우팅 리포트나 분석 칼럼처럼 신뢰감 있고 전문적이면서도 팬들이 흥미롭게 읽을 수 있는 톤앤매너로 작성해 주세요.
2. **플레이스타일 및 스탯 분석**: 제공된 시즌 평균 KDA 지표 및 킬/데스 비율을 바탕으로 이 선수의 장단점과 게임 기여도(메인 캐리력, 안정성, 지원 성향 등)를 분석해 주세요.
3. **최근 폼 평가**: 최근 5경기 출전 성적(챔피언 기용 패턴, 승패 흐름, KDA 변화 등)을 기반으로 선수의 현재 기세와 폼을 세부적으로 평가해 주세요.
4. **향후 전망**: 이 선수가 속한 팀의 성적 향상을 위해 앞으로 어떤 메타 적응이나 역할 수행이 기대되는지 총평을 작성해 주세요.
5. **출력 형식**: Markdown 문법을 사용하여 깔끔하게 타이틀(h3)과 본문 단락을 나누어 작성해 주세요.
6. **언어**: 반드시 자연스럽고 매끄러운 한국어로 작성해 주세요.
`;
  }

  /**
   * 경기 데이터를 기반으로 AI 승부를 예측합니다.
   */
  async generateMatchPrediction(matchDetail: any): Promise<{ winnerTeamShortName: string; probability: number; reason: string }> {
    if (!this.genAI) {
      throw new Error(
        'Gemini API 키가 구성되지 않았습니다. .env 파일에 GEMINI_API_KEY를 설정해주세요.',
      );
    }

    const model = this.genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      generationConfig: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: SchemaType.OBJECT,
          properties: {
            winnerTeamShortName: {
              type: SchemaType.STRING,
              description: '예측된 승리 팀의 약칭 (예: T1, GEN, DK 등)',
            },
            probability: {
              type: SchemaType.INTEGER,
              description: '예측 승리 확률 (0 ~ 100 사이의 정수)',
            },
            reason: {
              type: SchemaType.STRING,
              description: '해당 예측을 내린 간략한 분석 이유 (한국어로 작성)',
            },
          },
          required: ['winnerTeamShortName', 'probability', 'reason'],
        },
      },
    });

    const prompt = this.buildMatchPredictionPrompt(matchDetail);

    try {
      this.logger.log(
        `Starting AI match prediction for match: ${matchDetail.id}`,
      );
      const result = await this.generateWithRetry(model, prompt);
      const text = result.response.text();
      return JSON.parse(text);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`AI match prediction failed: ${message}`);
      throw error;
    }
  }

  private buildMatchPredictionPrompt(match: any): string {
    const homeTeam = match.homeTeam;
    const awayTeam = match.awayTeam;

    return `당신은 LCK(LoL Champions Korea) e스포츠 전문 분석가이자 예측 시스템입니다.
제공된 두 팀의 매치업 데이터를 기반으로, 어떤 팀이 승리할 것인지 예측하고 그 확률과 타당한 이유를 분석해 주세요.

## [매치업 정보]
- 홈 팀: ${homeTeam.name} (${homeTeam.shortName})
  - 시즌 성적: ${homeTeam.wins ?? 0}승 ${homeTeam.losses ?? 0}패 (순위: ${homeTeam.rank ?? '기록 없음'})
  - 세트 득실차: ${homeTeam.setDifferential ?? 0} (세트승: ${homeTeam.setWins ?? 0}, 세트패: ${homeTeam.setLosses ?? 0})
- 어웨이 팀: ${awayTeam.name} (${awayTeam.shortName})
  - 시즌 성적: ${awayTeam.wins ?? 0}승 ${awayTeam.losses ?? 0}패 (순위: ${awayTeam.rank ?? '기록 없음'})
  - 세트 득실차: ${awayTeam.setDifferential ?? 0} (세트승: ${awayTeam.setWins ?? 0}, 세트패: ${awayTeam.setLosses ?? 0})

## [분석 요구사항]
1. 두 팀의 시즌 성적(승수, 패수, 세트 득실 등)을 철저히 비교 분석해 주세요.
2. 분석 근거를 바탕으로 더 우세할 것으로 예측되는 팀의 shortName(${homeTeam.shortName} 또는 ${awayTeam.shortName})을 지정해 주세요.
3. 승리 확률(%)과 분석 이유를 자연스럽고 정갈한 한국어로 반환해 주세요.
`;
  }

  /**
   * 일시적인 서버 부하(503, 429) 시 지수 백오프로 재시도하는 공통 헬퍼 메소드입니다.
   */
  private async generateWithRetry(model: any, prompt: any, retries = 3, delay = 1000): Promise<any> {
    try {
      return await model.generateContent(prompt);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      const isRetryable =
        errorMessage.includes('503') ||
        errorMessage.includes('429') ||
        errorMessage.includes('Service Unavailable') ||
        errorMessage.includes('Resource has been exhausted') ||
        errorMessage.includes('high demand');

      if (isRetryable && retries > 0) {
        this.logger.warn(
          `AI API 호출에 일시적인 장애가 발생하여 ${delay}ms 후 재시도합니다... (남은 횟수: ${retries})`,
        );
        await new Promise((resolve) => setTimeout(resolve, delay));
        return this.generateWithRetry(model, prompt, retries - 1, delay * 2);
      }
      throw error;
    }
  }
}
