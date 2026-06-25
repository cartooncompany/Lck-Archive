import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  Inject,
} from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import * as cacheManager from 'cache-manager';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { GetRecentMatchesQueryDto } from './dto/get-recent-matches.query.dto';
import { MatchDetailResponseDto } from './responses/match-detail.response';
import {
  MatchListResponseDto,
  MatchSummaryResponseDto,
} from './responses/match-summary.response';
import { MatchesRepository } from './matches.repository';

@Injectable()
export class MatchesService {
  private readonly logger = new Logger(MatchesService.name);

  constructor(
    private readonly matchesRepository: MatchesRepository,
    @Inject(CACHE_MANAGER) private readonly cacheManager: cacheManager.Cache,
  ) {}

  async getMatches(query: GetMatchesQueryDto): Promise<MatchListResponseDto> {
    const cacheKey = `matches:list:${JSON.stringify(query)}`;
    const cached = await this.cacheManager.get<MatchListResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const [matches, total] = await Promise.all([
      this.matchesRepository.findMany(query),
      this.matchesRepository.count(query),
    ]);

    const result = {
      items: matches.map((match) => this.matchesRepository.toSummaryDto(match)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cacheManager.set(cacheKey, result, 5 * 60 * 1000); // 5분 캐싱
    return result;
  }

  async getRecentResults(
    query: GetRecentMatchesQueryDto,
  ): Promise<MatchSummaryResponseDto[]> {
    const cacheKey = `matches:recent:${JSON.stringify(query)}`;
    const cached = await this.cacheManager.get<MatchSummaryResponseDto[]>(cacheKey);
    if (cached) {
      return cached;
    }

    const limit = query.limit ?? 5;
    const result = await this.matchesRepository.findRecentResults(limit);

    await this.cacheManager.set(cacheKey, result, 5 * 60 * 1000); // 5분 캐싱
    return result;
  }

  async getMatchById(id: string): Promise<MatchDetailResponseDto> {
    const cacheKey = `match:detail:${id}`;
    const cached = await this.cacheManager.get<MatchDetailResponseDto>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for match detail: ${cacheKey}`);
      return cached;
    }

    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    const result = {
      ...this.matchesRepository.toDetailDto(match),
    };

    await this.cacheManager.set(cacheKey, result, 10 * 60 * 1000); // 10분 캐싱
    return result;
  }

}
