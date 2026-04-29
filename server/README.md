# LCK Archive Server

NestJS backend for LCK Archive. The server stores LCK teams, players, matches, news, auth data, and GRID-derived match state.

## Architecture

The server follows NestJS module boundaries with a pragmatic service/repository split.

```text
Controller -> Service -> Repository -> Prisma
```

Crawler modules use a separate ingestion flow:

```text
Client -> Parser/Mapper -> Job/Service -> Prisma
```

Do not add a separate Domain/UseCase layer unless a module develops complex business workflows that are reused across controllers, schedulers, and crawler jobs.

## Project Structure

```text
src/
  common/
    dto/
    entities/
    filters/
    responses/
    utils/
  database/
    prisma.service.ts
  modules/
    auth/
    matches/
    news/
    players/
    teams/
    users/
  crawler/
    lck/
      client/
      jobs/
      mapper/
      parser/
      responses/
      services/
      types/
    news/
      client/
      jobs/
      parser/
      responses/
      types/
  scheduler/
prisma/
  schema.prisma
  migrations/
docs/
```

## Layer Responsibilities

### Controller

- HTTP route boundary.
- Validate and receive DTO/query params through Nest decorators.
- Delegate behavior to services.
- Avoid direct Prisma access.

### Service

- Application behavior for a module.
- Coordinates repositories and other services.
- Owns authorization-sensitive decisions where applicable.
- Keeps controller methods thin.

### Repository

- Prisma query boundary.
- Builds query filters, includes/selects, and maps database records to response DTOs when that keeps services simpler.
- Avoid HTTP-specific behavior.

### Crawler Client

- External API boundary.
- Handles request construction, authentication headers, rate limits, and external API errors.
- Does not write to the database.

### Crawler Parser/Mapper

- Converts external payloads into raw normalized payloads.
- Keeps GRID/static source shape isolated from database upsert logic.

### Crawler Job/Service

- Orchestrates sync work.
- Upserts normalized data through Prisma.
- Owns stale-data cleanup and idempotency behavior.

## GRID Integration

The LCK crawler currently combines:

- Central/static data for teams, players, tournaments, series, schedules, and service coverage.
- Series State data for participants, games, per-game player stats, maps, winners, and draft actions.

Series Events over WebSocket are not part of the current Open Access path and should be treated as a future enhancement unless the product gains access.

Current priority for GRID-related code:

1. Keep static match metadata stable.
2. Store participants and game-level stats when Series State has them.
3. Log GraphQL error metadata clearly.
4. Respect GRID rate limits.
5. Avoid crawling private/protected content when official API data exists.

## Data Model

Prisma is the source of truth for persisted schema.

Important match-related models include:

- `Match`
- `MatchPlayerParticipation`
- `MatchGame`
- `MatchGamePlayerStat`
- `MatchDraftAction`

When adding persisted data:

- Add/adjust Prisma schema.
- Create a migration.
- Update repository response DTOs if the API should expose it.
- Update frontend DTO/model mapping only after the backend response shape is stable.

## Commands

```bash
pnpm install
docker compose up -d
cp .env.example .env.local
pnpm exec prisma generate
pnpm run start:dev
```

The default local Postgres container is exposed on host port `15432`.

`DATABASE_URL` should match:

```text
postgresql://postgres:postgres@localhost:15432/lck_archive
```

## Tests And Checks

```bash
pnpm run build
pnpm run test
pnpm run test:e2e
pnpm run test:cov
```

For focused Jest runs, use the relevant spec path. If local Watchman causes issues, run Jest with `--watchman=false`.

## Docs

- [Flutter API Integration Guide](./docs/flutter-api-integration-guide.md)
- [GRID API Integration Notes](./docs/grid-api-integration-notes.md)

## Practical Rules

- Keep Nest modules cohesive by feature.
- Prefer explicit Prisma queries over generic repository abstractions.
- Keep external API quirks inside crawler clients/parsers.
- Keep response DTOs stable for the Flutter app.
- Do not add layers for symmetry; add layers when they remove real coupling or repeated logic.
