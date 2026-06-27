import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { CacheInvalidatorService } from '../../common/cache/cache-invalidator.service';
import { CacheNamespace } from '../../common/cache/cache-namespaces';
import { buildCacheKey } from '../../common/utils/cache-key.util';
import { buildPaginationMeta } from '../../common/utils/pagination.util';
import { GetMatchesQueryDto } from './dto/get-matches.query.dto';
import { GetRecentMatchesQueryDto } from './dto/get-recent-matches.query.dto';
import { MatchMapper } from './matches.mapper';
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
    private readonly matchMapper: MatchMapper,
    private readonly cache: CacheInvalidatorService,
  ) {}

  async getMatches(query: GetMatchesQueryDto): Promise<MatchListResponseDto> {
    const cacheKey = buildCacheKey(CacheNamespace.MATCHES, 'list', query);
    const cached = await this.cache.get<MatchListResponseDto>(cacheKey);
    if (cached) {
      return cached;
    }

    const [matches, total] = await Promise.all([
      this.matchesRepository.findMany(query),
      this.matchesRepository.count(query),
    ]);

    const result = {
      items: matches.map((match) => this.matchMapper.toSummaryDto(match)),
      meta: buildPaginationMeta(query.page, query.limit, total),
    };

    await this.cache.set(
      CacheNamespace.MATCHES,
      cacheKey,
      result,
      5 * 60 * 1000,
    ); // 5분 캐싱
    return result;
  }

  async getRecentResults(
    query: GetRecentMatchesQueryDto,
  ): Promise<MatchSummaryResponseDto[]> {
    const cacheKey = buildCacheKey(CacheNamespace.MATCHES, 'recent', query);
    const cached = await this.cache.get<MatchSummaryResponseDto[]>(cacheKey);
    if (cached) {
      return cached;
    }

    const limit = query.limit ?? 5;
    const matches = await this.matchesRepository.findRecentResults(limit);
    const result = matches.map((match) => this.matchMapper.toSummaryDto(match));

    await this.cache.set(
      CacheNamespace.MATCHES,
      cacheKey,
      result,
      5 * 60 * 1000,
    ); // 5분 캐싱
    return result;
  }

  async getMatchById(id: string): Promise<MatchDetailResponseDto> {
    const cacheKey = buildCacheKey(CacheNamespace.MATCHES, 'detail', id);
    const cached = await this.cache.get<MatchDetailResponseDto>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for match detail: ${cacheKey}`);
      return cached;
    }

    const match = await this.matchesRepository.findById(id);

    if (!match) {
      throw new NotFoundException(`Match not found: ${id}`);
    }

    const result = this.matchMapper.toDetailDto(match);

    await this.cache.set(
      CacheNamespace.MATCHES,
      cacheKey,
      result,
      10 * 60 * 1000,
    ); // 10분 캐싱
    return result;
  }
}
