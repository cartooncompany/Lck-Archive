/**
 * 캐시 네임스페이스 상수.
 *
 * 각 서비스는 캐시 키의 prefix로 이 값을 사용하고, 동기화 작업은
 * 동일한 네임스페이스로 캐시를 무효화한다.
 */
export const CacheNamespace = {
  TEAMS: 'teams',
  PLAYERS: 'players',
  MATCHES: 'matches',
  NEWS: 'news',
} as const;

export type CacheNamespaceValue =
  (typeof CacheNamespace)[keyof typeof CacheNamespace];
