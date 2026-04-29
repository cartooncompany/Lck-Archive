# AGENTS.md

## Architecture

This Flutter app uses a lightweight feature-first layered architecture.
Do not force full Clean Architecture for simple API screens.

### Default Dependency Flow

```text
Presentation -> Repository -> DataSource -> API/Storage
```

- Presentation may depend on repositories and shared app models.
- Presentation must not import DTOs or call DataSources directly.
- Repository maps DTOs into app-facing models.
- DataSource only performs I/O.

### Optional Extended Flow

Use this only when a feature has meaningful business rules, multi-repository orchestration, or heavily reused behavior.

```text
Presentation -> UseCase -> Repository -> DataSource
```

Do not create one UseCase per simple CRUD/read operation by default.

## Folders

### `app`

- Router, theme, dependency assembly, app bootstrap.
- `AppDependencies` is the current DI composition root.

### `core`

- Cross-cutting infrastructure and utilities.
- Examples: network client, storage abstraction, error type, constants.
- No feature-specific business rules.

### `shared`

- Reusable app models, widgets, extensions, and utilities.
- Shared models are app-facing models, not API DTOs.
- Simple derived getters such as display text are allowed.
- API parsing and persistence logic should stay out of shared models.

### `features/{feature}/data`

- `datasource`: Remote/local I/O only.
- `dto`: API request/response shape only. Keep DTOs internal to data/repository.
- `repository`: Coordinates DataSource calls, maps DTOs to shared/app models, owns small cache/fallback behavior when needed.

### `features/{feature}/presentation`

- `pages`: screen-level widgets.
- `widgets`: feature-local UI pieces.
- `bloc` or controller: UI state and user actions.
- Presentation may contain screen state, formatting for layout, and navigation.
- Keep data fetching through repositories or use cases.

## Rules

- Keep the current lightweight structure unless complexity proves otherwise.
- Do not add `domain`, repository interfaces, or use cases just for symmetry.
- Add a use case when it removes real duplication or isolates non-trivial business logic.
- DTOs must not leak into presentation.
- DataSources must not contain mapping or UI logic.
- Reusable widgets go in `shared/widgets`; screen-specific widgets stay inside the feature.
- Avoid large generic abstractions until at least two real call sites need them.

## Commands

- `flutter pub get`
- `flutter analyze`
- `dart format .`
- `flutter test`
- `flutter run`

## Conventions

- snake_case: files
- PascalCase: classes
- `_`: private members
- Prefer `const` widgets where it stays readable.
- Add comments only when they explain non-obvious logic or external constraints.

## Commit

- Commit message prefixes:
  - `feat:` 기능 추가
  - `fix:` 버그 수정
  - `refactor:` 리팩토링
  - `chore:` 기타 작업
  - `test:` 테스트 관련
- 커밋 메시지는 영어로 작성.
- 한 커밋에는 하나의 변경 의도를 담는다.
- 커밋 전 기본 확인:
  - `flutter analyze`
  - `flutter test`
