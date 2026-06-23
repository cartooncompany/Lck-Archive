import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { GetRecentMatchesQueryDto } from './dto/get-recent-matches.query.dto';
import { MatchDetailResponseDto } from './responses/match-detail.response';
import {
  MatchListResponseDto,
  MatchSummaryResponseDto,
} from './responses/match-summary.response';
import { MatchesRepository } from './matches.repository';
import { AiService } from '../ai/ai.service';

@Injectable()
export class MatchesService {
  constructor(
    private readonly matchesRepository: MatchesRepository,
    private readonly aiService: AiService,
  ) {}

  async getMatches(query: GetMatchesQueryDto): Promise<MatchListResponseDto> {
    const [matches, total] = await Promise.all([
      this.matchesRepository.findMany(query),
      this.matchesRepository.count(query),
    ]);

    return {
      items: matches.map((match) => this.matchesRepository.toSummaryDto(match)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };
  }

  async getRecentResults(
    query: GetRecentMatchesQueryDto,
  ): Promise<MatchSummaryResponseDto[]> {
    const limit = query.limit ?? 5;
    return this.matchesRepository.findRecentResults(limit);
  }

  async getMatchById(id: string): Promise<MatchDetailResponseDto> {
    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    return {
      ...this.matchesRepository.toDetailDto(match),
    };
  }

  async generateAiSummary(id: string): Promise<string> {
    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    if (match.status !== 'COMPLETED') {
      throw new BadRequestException(
        `Cannot generate AI summary for non-completed match: ${id}`,
      );
    }

    const matchDetailDto = this.matchesRepository.toDetailDto(match);
    const summary = await this.aiService.generateMatchSummary(matchDetailDto);

    await this.matchesRepository.updateAiSummary(id, summary);

    return summary;
  }

  async generateAiPrediction(id: string): Promise<{ aiWinnerTeamId: string; aiPrediction: string }> {
    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    if (match.status !== 'SCHEDULED') {
      throw new BadRequestException(
        `Cannot generate AI prediction for non-scheduled match: ${id}`,
      );
    }

    const matchDetailDto = this.matchesRepository.toDetailDto(match);
    const predictionResult = await this.aiService.generateMatchPrediction(matchDetailDto);

    let aiWinnerTeamId = match.homeTeamId;
    if (predictionResult.winnerTeamShortName.toUpperCase() === match.awayTeam.shortName.toUpperCase()) {
      aiWinnerTeamId = match.awayTeamId;
    } else if (predictionResult.winnerTeamShortName.toUpperCase() === match.homeTeam.shortName.toUpperCase()) {
      aiWinnerTeamId = match.homeTeamId;
    }

    const aiPredictionStr = JSON.stringify({
      probability: predictionResult.probability,
      reason: predictionResult.reason,
      winnerTeamName: predictionResult.winnerTeamShortName,
    });

    await this.matchesRepository.updateAiPrediction(id, aiWinnerTeamId, aiPredictionStr);

    return { aiWinnerTeamId, aiPrediction: aiPredictionStr };
  }
}
