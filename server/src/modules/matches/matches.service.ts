import { Injectable, NotFoundException } from '@nestjs/common';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { MatchDetailResponseDto } from './responses/match-detail.response';
import { MatchListResponseDto } from './responses/match-summary.response';
import { MatchesRepository } from './matches.repository';

@Injectable()
export class MatchesService {
  constructor(private readonly matchesRepository: MatchesRepository) {}

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

  async getMatchById(id: string): Promise<MatchDetailResponseDto> {
    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    return this.matchesRepository.toDetailDto(match);
  }
}
