# GRID API 연동 메모

이 문서는 `/Users/taejun/Desktop/Lck-Archive/server` 기준 현재 코드와 GRID 가이드를 대조해서 정리한 메모다.

## 1. 현재 코드에 바로 적용된 내용

- API 키 환경변수로 `GRID_API_KEY`를 사용할 수 있다.
- 기존 호환성을 위해 `LOLESPORTS_API_KEY`도 계속 읽는다.
- 인증 방식은 GRID 가이드와 동일하게 `x-api-key` 헤더를 사용한다.

관련 코드는 `src/crawler/lck/client/lck-api.client.ts` 에 있다.

## 2. 지금 당장 넣어야 하는 env

```env
GRID_API_KEY="YOUR_GRID_API_KEY"
LCK_SYNC_ENABLED="true"
NEWS_SYNC_ENABLED="true"
LOLESPORTS_API_URL="https://esports-api.lolesports.com/persisted/gw"
LOLESPORTS_API_LOCALE="ko-KR"
LCK_LEAGUE_ID="98767991310872058"
LCK_TOURNAMENT_ID="113503260417890076"
LCK_SCHEDULE_PAGE_LIMIT="12"
```

## 3. 중요한 차이점

사용자가 전달한 GRID 가이드의 주요 엔드포인트는 아래 두 계열이다.

- `https://api.grid.gg/central-data/graphql`
- `https://api.grid.gg/file-download/...`

하지만 현재 서버의 LCK 크롤러는 아래 엔드포인트 구조를 전제로 구현돼 있다.

- `/getStandings`
- `/getSchedule`
- `/getTeams`

즉, 현재 코드는 "x-api-key 헤더 인증 방식"은 맞지만, 데이터 모델과 엔드포인트 구조는 GRID Central Data GraphQL 기준으로 작성돼 있지 않다.

## 4. 따라서 가능한 것과 불가능한 것

가능한 것:

- `GRID_API_KEY`를 env에 넣고 현재 헤더 인증 구조에 반영
- 기존 LCK 클라이언트의 설정 명확화

바로 불가능한 것:

- `GRID_API_URL=https://api.grid.gg` 만 넣어서 현재 `LckApiClient`를 그대로 동작시키는 것
- `central-data/graphql` 응답을 현재 `LckParser`에 그대로 연결하는 것

## 5. 실제 GRID 전환에 필요한 다음 작업

1. `GridCentralDataClient`를 별도로 만든다.
2. `allSeries` GraphQL 쿼리로 LOL 시리즈 목록을 가져온다.
3. 필요한 경우 `file-download` API로 시리즈별 데이터 파일을 가져온다.
4. GRID 응답을 현재 내부 모델(`RawLckTeamPayload`, `RawLckPlayerPayload`, `RawLckMatchPayload`)로 매핑하는 새 parser를 만든다.
5. 기존 `LckSyncJob`에서 데이터 소스를 선택할 수 있게 분기한다.

## 6. 결론

이번 반영으로 `GRID_API_KEY` 자체는 바로 넣을 수 있다. 다만 GRID 문서의 GraphQL / file-download API를 실제로 쓰려면, 현재 LCK 크롤러와는 별도의 GRID 전용 클라이언트와 매퍼를 추가해야 한다.
