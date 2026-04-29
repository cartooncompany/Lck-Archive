# LCK Archive Frontend

Flutter client for LCK Archive. The app consumes the NestJS API, renders teams, players, matches, news, authentication, favorite team state, and match prediction UI.

## Architecture

The frontend intentionally uses a lightweight feature-first layered architecture.

```text
Presentation -> Repository -> DataSource -> API/Storage
```

This is the default flow. A full Domain/UseCase layer is optional and should only be introduced when a feature has enough business complexity to justify it.

## Project Structure

```text
lib/
  app/
    app.dart
    app_dependencies.dart
    app_dependencies_scope.dart
    router/
    theme/
  core/
    constants/
    enums/
    error/
    network/
    storage/
  shared/
    extensions/
    models/
    utils/
    widgets/
  features/
    auth/
    favorite_team/
    home/
    matches/
    my_page/
    news/
    players/
    settings/
    teams/
```

## Layer Responsibilities

### `app`

Application composition and global wiring.

- `AppDependencies` builds repositories, data sources, network client, and local storage.
- Router and theme live here.
- Avoid feature-specific logic in this layer.

### `core`

Cross-cutting infrastructure.

- API client abstractions and Dio implementation
- API base URL resolution
- local storage abstraction
- shared error type
- constants and enums

`core` should not know about teams, players, matches, or news business rules.

### `shared`

Reusable app-facing code.

- Models used by presentation across features
- Reusable widgets
- Extensions and small utilities

Shared models are not API DTOs. They may contain simple derived getters such as `note` or `kdaText`, but should not parse API JSON or perform I/O.

### `features/{feature}/data`

API and persistence boundary for a feature.

```text
data/
  datasource/
  dto/
  repository/
```

- `datasource`: performs HTTP/local I/O only.
- `dto`: mirrors API request/response shapes.
- `repository`: calls data sources, maps DTOs into app models, and owns small cache/fallback logic when needed.

Repositories are currently concrete classes. Do not add repository interfaces until tests or multiple implementations make the indirection useful.

### `features/{feature}/presentation`

UI and screen state.

```text
presentation/
  pages/
  widgets/
  bloc/        # only where controller-style state already exists
  utils/       # presentation-only helpers
```

- Pages compose screen-level UI and call repositories through `AppDependenciesScope`.
- Widgets stay feature-local unless reused by multiple features.
- Controllers/blocs handle UI state and user actions.
- Presentation must not import DTOs or call data sources directly.

## When To Add UseCases Or Domain

Do not add use cases for every simple API call. Add a use case only when at least one of these is true:

- The behavior coordinates multiple repositories.
- The same business rule is reused by multiple screens.
- The logic is complex enough that testing it outside UI/repository code is clearly valuable.
- A feature needs multiple repository implementations.

If added, use this extended flow only for that feature:

```text
Presentation -> UseCase -> Repository -> DataSource
```

## Naming Rules

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Private members: `_camelCase`
- API models: suffix with `Dto`
- App-facing models: no `Dto` suffix
- Remote I/O: suffix with `RemoteDataSource`
- Repository: suffix with `Repository`

## Practical Rules

- Keep DTOs inside data/repository boundaries.
- Keep DataSources free of mapping and UI decisions.
- Prefer repository-level mapping from DTO to app model.
- Keep reusable widgets in `shared/widgets`.
- Keep one-off screen widgets in their feature folder.
- Avoid generic abstractions until at least two real use cases need them.
- Comments should explain non-obvious constraints, not restate code.

## Commands

```bash
flutter pub get
flutter analyze
dart format .
flutter test
flutter run
```

## Notes

The current app already has some pragmatic cross-feature dependencies, such as the players repository using the teams repository for team-name search support. This is acceptable while it remains simple and explicit. If more cross-feature orchestration appears, move that behavior into a use case instead of adding more repository-to-repository coupling.
