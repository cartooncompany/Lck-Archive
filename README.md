# LCK Archive

LCK Archive is a Flutter + NestJS project for browsing LCK teams, players, schedules, match results, news, and GRID-derived match details.

## Apps

```text
frontend/  Flutter app
server/    NestJS API server
```

## Architecture Summary

The project uses pragmatic layered architecture rather than full Clean Architecture everywhere.

Frontend default flow:

```text
Presentation -> Repository -> DataSource -> API/Storage
```

Backend default flow:

```text
Controller -> Service -> Repository -> Prisma
```

Crawler ingestion flow:

```text
Client -> Parser/Mapper -> Job/Service -> Prisma
```

Use cases, domain repository interfaces, or extra abstraction layers should be added only when they remove real duplication, isolate meaningful business rules, or make testing materially easier.

## Documentation

- [Frontend architecture](./frontend/README.md)
- [Frontend agent rules](./frontend/AGENTS.md)
- [Server architecture](./server/README.md)
- [GRID integration notes](./server/docs/grid-api-integration-notes.md)
- [Flutter API integration guide](./server/docs/flutter-api-integration-guide.md)

## Common Commands

Frontend:

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
```

Server:

```bash
cd server
pnpm install
docker compose up -d
pnpm exec prisma generate
pnpm run build
pnpm run test
```
