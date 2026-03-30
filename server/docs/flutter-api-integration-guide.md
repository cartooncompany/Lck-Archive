# Flutter API 연동 가이드

이 문서는 `/Users/taejun/Desktop/Lck-Archive/server` 기준 현재 구현되어 있는 API만 바탕으로 작성했다.  
대상 서버는 NestJS이며 전역 prefix는 `/api`, Swagger UI 경로는 `/docs`다.

## 1. 서버 기본 정보

- Base URL: `http://localhost:3000/api`
- Swagger UI: `http://localhost:3000/docs`
- CORS: 활성화됨
- 날짜 필드: ISO-8601 문자열로 내려옴
- 페이지네이션 기본값: `page=1`, `limit=20`
- 페이지네이션 최대값: `limit=100`

Flutter에서 로컬 서버에 붙을 때는 플랫폼별 주소를 다르게 잡는 편이 안전하다.

| 환경                          | 권장 Base URL                         |
| ----------------------------- | ------------------------------------- |
| Android Emulator              | `http://10.0.2.2:3000/api`            |
| iOS Simulator                 | `http://127.0.0.1:3000/api`           |
| macOS/Windows Flutter Desktop | `http://localhost:3000/api`           |
| 실제 기기                     | `http://<개발 PC의 로컬 IP>:3000/api` |

## 2. 공통 규칙

### 2.1 목록 응답 형식

목록 API는 모두 아래 구조를 따른다.

```json
{
  "items": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

### 2.2 공통 에러 처리

커스텀 에러 포맷은 아직 없고, NestJS 기본 예외 응답을 사용한다.

- 잘못된 쿼리 파라미터: `400`
- 존재하지 않는 리소스: `404`

예상 응답 예시:

```json
{
  "statusCode": 404,
  "message": "Team not found: clx123team",
  "error": "Not Found"
}
```

참고: 위 에러 바디 형식은 코드상 별도 예외 필터가 없으므로 NestJS 기본 동작을 따른다는 전제에서 정리했다.

### 2.3 Enum 값

#### `PlayerPosition`

- `TOP`
- `JUNGLE`
- `MID`
- `ADC`
- `SUPPORT`
- `COACH`
- `SUBSTITUTE`
- `FLEX`

#### `MatchStatus`

- `SCHEDULED`
- `COMPLETED`
- `CANCELED`

## 3. 현재 사용 가능한 API

### 3.1 Health

#### `GET /health`

서버 상태 확인용이다.

응답 예시:

```json
{
  "service": "LCK Archive API",
  "version": "0.1.0",
  "timestamp": "2026-03-30T10:00:00.000Z"
}
```

### 3.2 Teams

#### `GET /teams`

팀 목록 조회.

쿼리 파라미터:

| 이름      | 타입   | 필수   | 설명                                    |
| --------- | ------ | ------ | --------------------------------------- |
| `page`    | int    | 아니오 | 기본값 `1`                              |
| `limit`   | int    | 아니오 | 기본값 `20`, 최대 `100`                 |
| `keyword` | string | 아니오 | 팀명 또는 약칭 검색, 대소문자 구분 없음 |

정렬:

- `rank ASC`
- `wins DESC`
- `name ASC`

응답 item 필드:

| 필드              | 타입   | nullable | 설명        |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 아니오   | 팀 ID       |
| `name`            | string | 아니오   | 팀명        |
| `shortName`       | string | 아니오   | 약칭        |
| `logoUrl`         | string | 예       | 로고 URL    |
| `rank`            | int    | 예       | 순위        |
| `wins`            | int    | 아니오   | 매치 승 수  |
| `losses`          | int    | 아니오   | 매치 패 수  |
| `setWins`         | int    | 아니오   | 세트 승 수  |
| `setLosses`       | int    | 아니오   | 세트 패 수  |
| `setDifferential` | int    | 아니오   | 세트 득실차 |

예시:

```http
GET /api/teams?page=1&limit=10&keyword=T1
```

#### `GET /teams/:id`

팀 상세 조회.

추가 응답 필드:

| 필드         | 타입           | 설명                               |
| ------------ | -------------- | ---------------------------------- |
| `recentForm` | `List<String>` | 최근 5경기 결과, 값은 `W` 또는 `L` |

예시:

```json
{
  "id": "clx123team",
  "name": "T1",
  "shortName": "T1",
  "logoUrl": "https://cdn.example.com/teams/t1.png",
  "rank": 1,
  "wins": 15,
  "losses": 3,
  "setWins": 18,
  "setLosses": 8,
  "setDifferential": 10,
  "recentForm": ["W", "W", "L", "W", "L"]
}
```

#### `GET /teams/:id/matches`

특정 팀의 경기 목록 조회.

쿼리 파라미터:

| 이름         | 타입              | 필수   | 설명                                 |
| ------------ | ----------------- | ------ | ------------------------------------ |
| `page`       | int               | 아니오 | 기본값 `1`                           |
| `limit`      | int               | 아니오 | 기본값 `20`, 최대 `100`              |
| `seasonYear` | int               | 아니오 | `2020` 이상                          |
| `split`      | string            | 아니오 | 예: `SPRING`                         |
| `stage`      | string            | 아니오 | 예: `ROUND 1`                        |
| `status`     | enum              | 아니오 | `SCHEDULED`, `COMPLETED`, `CANCELED` |
| `from`       | string(date-time) | 아니오 | 이 시각 이후 경기만 조회             |
| `to`         | string(date-time) | 아니오 | 이 시각 이전 경기만 조회             |
| `sortOrder`  | enum              | 아니오 | `asc`, `desc`                        |

주의:

- `teamId`는 path param의 `:id`로 강제된다.
- `split`, `stage`는 현재 enum이 아니라 문자열 exact match다.
- 일정 화면은 `status=SCHEDULED&from=<현재시각>&sortOrder=asc` 조합을 권장한다.

### 3.3 Players

#### `GET /players`

선수 목록 조회.

쿼리 파라미터:

| 이름       | 타입   | 필수   | 설명                               |
| ---------- | ------ | ------ | ---------------------------------- |
| `page`     | int    | 아니오 | 기본값 `1`                         |
| `limit`    | int    | 아니오 | 기본값 `20`, 최대 `100`            |
| `teamId`   | string | 아니오 | 팀 ID exact match                  |
| `position` | enum   | 아니오 | `PlayerPosition`                   |
| `keyword`  | string | 아니오 | 선수 이름 검색, 대소문자 구분 없음 |

정렬:

- `teamId ASC`
- `name ASC`

주의:

- `keyword`는 현재 선수 이름만 검색한다.
- 현재 Flutter의 선수 목록 화면처럼 팀명까지 한 번에 검색하려면 프론트에서 팀 필터를 별도로 붙이거나 백엔드 검색 조건을 확장해야 한다.

응답 item 필드:

| 필드               | 타입   | nullable | 설명              |
| ------------------ | ------ | -------- | ----------------- |
| `id`               | string | 아니오   | 선수 ID           |
| `name`             | string | 아니오   | 선수명            |
| `position`         | string | 아니오   | 포지션 enum       |
| `profileImageUrl`  | string | 예       | 프로필 이미지 URL |
| `recentMatchCount` | int    | 아니오   | 최근 경기 수      |
| `team`             | object | 예       | 소속 팀 요약 정보 |

`team` 객체 필드:

```json
{
  "id": "clx123team",
  "shortName": "T1",
  "name": "T1",
  "logoUrl": "https://cdn.example.com/teams/t1.png"
}
```

#### `GET /players/:id`

선수 상세 조회.

추가 응답 필드:

| 필드          | 타입              | nullable | 설명     |
| ------------- | ----------------- | -------- | -------- |
| `realName`    | string            | 예       | 실명     |
| `nationality` | string            | 예       | 국적     |
| `birthDate`   | string(date-time) | 예       | 생년월일 |

### 3.4 Matches

#### `GET /matches`

경기 목록 조회.

쿼리 파라미터:

| 이름         | 타입              | 필수   | 설명                         |
| ------------ | ----------------- | ------ | ---------------------------- |
| `page`       | int               | 아니오 | 기본값 `1`                   |
| `limit`      | int               | 아니오 | 기본값 `20`, 최대 `100`      |
| `teamId`     | string            | 아니오 | 홈/원정 팀 ID 중 하나와 일치 |
| `seasonYear` | int               | 아니오 | `2020` 이상                  |
| `split`      | string            | 아니오 | 예: `SPRING`                 |
| `stage`      | string            | 아니오 | 예: `ROUND 1`                |
| `status`     | enum              | 아니오 | `MatchStatus`                |
| `from`       | string(date-time) | 아니오 | 이 시각 이후 경기만 조회     |
| `to`         | string(date-time) | 아니오 | 이 시각 이전 경기만 조회     |
| `sortOrder`  | enum              | 아니오 | `asc`, `desc`                |

정렬:

- 기본값: `scheduledAt DESC`
- 일정 화면은 `sortOrder=asc` 권장

응답 item 필드:

| 필드          | 타입              | nullable | 설명           |
| ------------- | ----------------- | -------- | -------------- |
| `id`          | string            | 아니오   | 경기 ID        |
| `scheduledAt` | string(date-time) | 아니오   | 경기 시작 시각 |
| `seasonYear`  | int               | 아니오   | 시즌 연도      |
| `split`       | string            | 아니오   | 시즌 split     |
| `stage`       | string            | 아니오   | stage          |
| `status`      | string            | 아니오   | 경기 상태      |
| `homeTeam`    | object            | 아니오   | 홈 팀          |
| `awayTeam`    | object            | 아니오   | 원정 팀        |
| `score`       | object            | 아니오   | 홈/원정 스코어 |
| `winner`      | object            | 예       | 승리 팀        |

응답 예시:

```json
{
  "id": "clx123match",
  "scheduledAt": "2026-03-30T09:00:00.000Z",
  "seasonYear": 2026,
  "split": "SPRING",
  "stage": "ROUND 1",
  "status": "COMPLETED",
  "homeTeam": {
    "id": "teamA",
    "shortName": "T1",
    "name": "T1",
    "logoUrl": "https://cdn.example.com/teams/t1.png"
  },
  "awayTeam": {
    "id": "teamB",
    "shortName": "GEN",
    "name": "Gen.G",
    "logoUrl": "https://cdn.example.com/teams/geng.png"
  },
  "score": {
    "home": 2,
    "away": 1
  },
  "winner": {
    "id": "teamA",
    "shortName": "T1",
    "name": "T1",
    "logoUrl": "https://cdn.example.com/teams/t1.png"
  }
}
```

#### `GET /matches/:id`

경기 상세 조회.

추가 응답 필드:

| 필드           | 타입   | nullable | 설명           |
| -------------- | ------ | -------- | -------------- |
| `matchNumber`  | string | 예       | 경기 번호      |
| `vodUrl`       | string | 예       | VOD 링크       |
| `participants` | list   | 아니오   | 출전 선수 목록 |

`participants` item 필드:

| 필드         | 타입   | 설명         |
| ------------ | ------ | ------------ |
| `playerId`   | string | 선수 ID      |
| `playerName` | string | 선수명       |
| `position`   | string | 포지션       |
| `isStarter`  | bool   | 선발 여부    |
| `team`       | object | 팀 요약 정보 |

### 3.5 Crawler

#### `POST /crawler/lck/sync`

LoL Esports 공식 API에서 LCK 팀/선수/경기 데이터를 수동 동기화한다.

응답 예시:

```json
{
  "teams": 10,
  "players": 60,
  "matches": 90
}
```

운영 메모:

- 자동 동기화는 `LCK_SYNC_ENABLED=true`일 때만 동작한다.
- 스케줄러 주기는 6시간마다이며, 시간대는 `Asia/Seoul`이다.
- `getSchedule` 페이지 토큰을 따라가며 수집하므로 현재 기준 전후 일정이 함께 갱신된다.

## 4. Flutter 연동 시 권장 구조

현재 프론트엔드에는 `/Users/taejun/Desktop/Lck-Archive/frontend/lib/core/network/api_client.dart`가 있지만 `get<T>(String path)` 한 줄짜리 추상화라서, 실제 쿼리 파라미터와 디코딩을 처리하기에는 부족하다.

권장 구조:

```text
lib/
  core/
    network/
      api_client.dart
      dio_api_client.dart
      api_exception.dart
      pagination_meta.dart
      paged_response.dart
  features/
    teams/
      data/
        dto/
          team_summary_dto.dart
          team_detail_dto.dart
        datasource/
          teams_remote_data_source.dart
        repository/
          teams_repository.dart
    players/
      data/
    matches/
      data/
```

### 4.1 `ApiClient` 추상화 예시

```dart
abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  });
}
```

### 4.2 `dio` 기반 구현 예시

`pubspec.yaml`에 아래 의존성 추가를 권장한다.

```yaml
dependencies:
  dio: ^5.9.0
```

구현 예시:

```dart
import 'package:dio/dio.dart';

import '../error/app_failure.dart';
import 'api_client.dart';

class DioApiClient implements ApiClient {
  DioApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        );

  final Dio _dio;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return decoder(response.data);
    } on DioException catch (error) {
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message']?.toString() ?? 'API 요청 실패')
          : 'API 요청 실패';
      throw AppFailure(message);
    }
  }
}
```

### 4.3 공통 페이지네이션 모델 예시

```dart
class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class PagedResponse<T> {
  const PagedResponse({
    required this.items,
    required this.meta,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic> json) itemDecoder,
  }) {
    final rawItems = json['items'] as List<dynamic>;
    return PagedResponse(
      items: rawItems
          .map((item) => itemDecoder(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  final List<T> items;
  final PaginationMeta meta;
}
```

### 4.4 Teams remote data source 예시

```dart
class TeamsRemoteDataSource {
  const TeamsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResponse<TeamSummaryDto>> getTeams({
    String? keyword,
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get(
      '/teams',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
      decoder: (data) => PagedResponse<TeamSummaryDto>.fromJson(
        data as Map<String, dynamic>,
        itemDecoder: TeamSummaryDto.fromJson,
      ),
    );
  }

  Future<TeamDetailDto> getTeamDetail(String id) {
    return _apiClient.get(
      '/teams/$id',
      decoder: (data) => TeamDetailDto.fromJson(data as Map<String, dynamic>),
    );
  }
}
```

### 4.5 DateTime 파싱

서버의 `scheduledAt`, `birthDate`, `timestamp`는 문자열로 내려오므로 DTO에서 직접 `DateTime.parse()`로 변환하면 된다.

```dart
final scheduledAt = DateTime.parse(json['scheduledAt'] as String);
```

## 5. 현재 Flutter 앱에 맞춘 연동 포인트

현재 프론트엔드의 presentation model은 서버 응답과 1:1 대응하지 않는다.  
특히 `/Users/taejun/Desktop/Lck-Archive/frontend/lib/shared/models/team_summary.dart`와 `/Users/taejun/Desktop/Lck-Archive/frontend/lib/shared/models/player_profile.dart`는 화면 표시용 정보까지 같이 들고 있어서 API DTO를 곧바로 대입하기 어렵다.

권장 방식:

1. 서버 응답과 동일한 DTO를 `data/dto`에 만든다.
2. DTO를 화면 전용 ViewModel 또는 presentation model로 변환한다.
3. API에 없는 값은 UI에서 제거하거나, 별도 API가 생기기 전까지 mock/fallback으로 유지한다.

### 5.1 화면별 매핑

| 화면                   | 바로 연동 가능한 API                      | 비고                                 |
| ---------------------- | ----------------------------------------- | ------------------------------------ |
| 팀 목록                | `GET /teams`                              | 검색도 `keyword`로 바로 가능         |
| 팀 상세 상단 정보      | `GET /teams/:id`                          | `recentForm` 포함                    |
| 팀 상세 최근 경기      | `GET /teams/:id/matches?status=COMPLETED` | `limit`로 개수 제어                  |
| 팀 상세 소속 선수      | `GET /players?teamId=:id`                 | 선수 목록 연동 가능                  |
| 선수 목록              | `GET /players`                            | `keyword`, `position`, `teamId` 지원 |
| 선수 상세 기본 정보    | `GET /players/:id`                        | 실명, 국적, 생년월일까지 가능        |
| 경기 목록 화면 추가 시 | `GET /matches`                            | 팀/시즌/상태/기간/정렬 필터 가능     |
| 경기 상세 화면 추가 시 | `GET /matches/:id`                        | 출전 선수 목록 포함                  |

### 5.2 현재 API만으로는 부족한 화면 데이터

| 화면/영역                  | 현재 API 상태   | 대응 방법                                           |
| -------------------------- | --------------- | --------------------------------------------------- |
| 홈 뉴스                    | API 없음        | mock 유지 또는 뉴스 API 추가 필요                   |
| 홈 주요 선수의 상세 지표   | API 없음        | `recentMatchCount` 정도만 활용하거나 API 추가 필요  |
| 선수 목록의 팀명 검색      | 직접 지원 안 함 | `teamId` 선택 UI로 대체하거나 백엔드 검색 확장 필요 |
| 선수 상세의 `keyStats`     | API 없음        | UI 축소 또는 통계 API 추가 필요                     |
| 선수 상세의 최근 출전 기록 | API 없음        | `GET /players/:id/matches` 같은 API 추가 필요       |
| 팀 상세의 `summary` 문구   | API 없음        | UI 문구 제거 또는 정적 문구 사용                    |
| 팀/선수 컬러 정보          | API 없음        | 프론트에서 로컬 매핑 테이블 유지                    |

## 6. 실전 연동 순서

가장 안전한 순서는 아래다.

1. `ApiClient`를 `dio` 기반으로 교체한다.
2. `GET /teams`, `GET /teams/:id`, `GET /teams/:id/matches`부터 붙인다.
3. `GET /players`, `GET /players/:id`를 붙인다.
4. 일정 화면이 필요하면 `GET /matches?status=SCHEDULED&from=<현재시각>&sortOrder=asc`부터 붙인다.
5. mock 데이터 의존 영역을 화면 단위로 제거한다.
6. 부족한 데이터는 백엔드 추가 API 요구사항으로 분리한다.

## 7. 추천 백엔드 추가 API

현재 Flutter 화면을 mock 없이 완전히 치환하려면 아래 API가 있으면 좋다.

- `GET /players/:id/matches`
- `GET /teams/:id/players`
- `GET /news` 또는 `GET /teams/:id/news`
- 선수 통계 전용 API
- 팀 소개/브랜딩 정보 API

## 8. 빠른 체크리스트

- Android Emulator면 `10.0.2.2`를 썼는지 확인
- 모든 목록 응답을 `items`, `meta` 구조로 파싱했는지 확인
- `limit`이 100을 넘지 않게 했는지 확인
- `split`, `stage`는 exact match 문자열로 보내는지 확인
- 일정 화면은 `status=SCHEDULED`, `from=<현재시각 ISO>`, `sortOrder=asc`를 같이 보내는지 확인
- nullable 필드(`logoUrl`, `rank`, `winner`, `birthDate`) 처리했는지 확인
- mock model과 API DTO를 분리했는지 확인

## 9. 프론트 일정 화면 메모

- LCK 예정 경기 목록은 `GET /matches?status=SCHEDULED&from=<현재시각 ISO>&sortOrder=asc`로 조회하면 된다.
- 월별/주간 범위를 자르고 싶으면 `to`를 함께 사용하면 된다.
- `scheduledAt`은 UTC ISO 문자열이다. Flutter에서는 `DateTime.parse()` 후 로컬 시간대로 보여주면 된다.
- 예정 경기는 `winner`가 `null`이고 `score.home`, `score.away`가 `0`일 수 있다. 완료 경기 카드와 같은 UI 로직을 그대로 재사용하면 안 된다.
- `stage` 값은 현재 `1주 차`, `2주 차`처럼 실제 노출 문자열이 내려온다. enum으로 가정하지 말고 그대로 노출하는 편이 안전하다.
- 데이터가 비어 있으면 먼저 `POST /crawler/lck/sync`가 실행됐는지 확인해야 한다.

예시:

```http
GET /api/matches?status=SCHEDULED&from=2026-03-30T00:00:00.000Z&sortOrder=asc&limit=20
```
