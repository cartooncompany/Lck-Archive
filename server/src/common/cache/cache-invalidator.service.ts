import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Inject, Injectable, Logger } from '@nestjs/common';
import * as cacheManager from 'cache-manager';

/**
 * 네임스페이스 단위 캐시 무효화를 담당한다.
 *
 * cache-manager(v7)의 인메모리 스토어는 키 패턴 스캔(`keys('matches:*')`)을
 * 표준 API로 보장하지 않는다. 따라서 서비스가 캐시에 값을 저장할 때 키를
 * 네임스페이스별로 추적해 두고, 데이터 동기화 등으로 무효화가 필요할 때
 * 해당 네임스페이스의 키만 삭제한다.
 */
@Injectable()
export class CacheInvalidatorService {
  private readonly logger = new Logger(CacheInvalidatorService.name);
  private readonly keysByNamespace = new Map<string, Set<string>>();

  constructor(
    @Inject(CACHE_MANAGER) private readonly cacheManager: cacheManager.Cache,
  ) {}

  /**
   * 캐시 값을 저장하면서 키를 네임스페이스에 등록한다.
   * 서비스에서 `cacheManager.set` 대신 사용한다.
   */
  async set<T>(
    namespace: string,
    key: string,
    value: T,
    ttlMs: number,
  ): Promise<void> {
    await this.cacheManager.set(key, value, ttlMs);
    this.track(namespace, key);
  }

  /**
   * 캐시 값을 조회한다. (set과 짝을 이루는 편의 메서드)
   */
  async get<T>(key: string): Promise<T | undefined> {
    return this.cacheManager.get<T>(key);
  }

  /**
   * 캐시 키를 네임스페이스에 등록한다.
   */
  track(namespace: string, key: string): void {
    const keys = this.keysByNamespace.get(namespace) ?? new Set<string>();
    keys.add(key);
    this.keysByNamespace.set(namespace, keys);
  }

  /**
   * 지정한 네임스페이스들의 모든 캐시 키를 삭제한다.
   */
  async invalidate(...namespaces: string[]): Promise<void> {
    for (const namespace of namespaces) {
      const keys = this.keysByNamespace.get(namespace);
      if (!keys || keys.size === 0) {
        continue;
      }

      await Promise.all([...keys].map((key) => this.cacheManager.del(key)));
      this.keysByNamespace.delete(namespace);
      this.logger.log(
        `Invalidated ${keys.size} cache entries for namespace "${namespace}".`,
      );
    }
  }
}
