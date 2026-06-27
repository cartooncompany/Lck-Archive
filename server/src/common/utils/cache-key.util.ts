/**
 * 객체를 캐시 키로 안정적으로 직렬화한다.
 *
 * `JSON.stringify`는 키 순서를 보장하지 않으므로 동일한 의미의 쿼리라도
 * 키 입력 순서가 다르면 서로 다른 캐시 키가 생성되어 불필요한 캐시 미스가
 * 발생한다. 이 함수는 객체 키를 재귀적으로 정렬하여 항상 동일한 결과를
 * 보장한다.
 */
export function stableSerialize(value: unknown): string {
  return JSON.stringify(normalize(value));
}

/**
 * 네임스페이스와 파라미터로 캐시 키를 구성한다.
 *
 * 예: buildCacheKey('matches', 'list', query) => "matches:list:{...}"
 */
export function buildCacheKey(
  namespace: string,
  scope: string,
  params?: unknown,
): string {
  const base = `${namespace}:${scope}`;
  if (params === undefined || params === null) {
    return base;
  }
  return `${base}:${stableSerialize(params)}`;
}

function normalize(value: unknown): unknown {
  if (value === null || typeof value !== 'object') {
    return value;
  }

  if (Array.isArray(value)) {
    return value.map((item) => normalize(item));
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  const record = value as Record<string, unknown>;
  return Object.keys(record)
    .sort()
    .reduce<Record<string, unknown>>((acc, key) => {
      const normalized = normalize(record[key]);
      if (normalized !== undefined) {
        acc[key] = normalized;
      }
      return acc;
    }, {});
}
