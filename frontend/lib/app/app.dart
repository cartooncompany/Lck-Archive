import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/auth/presentation/pages/splash_page.dart';
import 'package:frontend/features/favorite_team/domain/usecases/toggle_favorite_team_usecase.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'app_dependencies.dart';
import 'app_dependencies_scope.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LckArchiveApp extends StatefulWidget {
  const LckArchiveApp({super.key});

  @override
  State<LckArchiveApp> createState() => _LckArchiveAppState();
}

class _LckArchiveAppState extends State<LckArchiveApp> {
  late final Future<_AppBootstrapData> _bootstrapFuture;
  FavoriteTeamController? _favoriteTeamController;
  SessionController? _sessionController;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  @override
  void dispose() {
    _favoriteTeamController?.dispose();
    _sessionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppBootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildApp(
            AppRouter.singlePageRouter(
              _AppErrorScreen(
                message: '앱 초기화 중 오류가 발생했습니다.\n${snapshot.error}',
              ),
            ),
            context,
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return _buildApp(AppRouter.singlePageRouter(const SplashPage()), context);
        }

        final bootstrapData = snapshot.data!;
        final dependencies = bootstrapData.dependencies;
        _favoriteTeamController ??= bootstrapData.favoriteTeamController;
        _sessionController ??= bootstrapData.sessionController;
        _router ??= AppRouter.createRouter(
          sessionController: _sessionController!,
        );

        return AppDependenciesScope(
          dependencies: dependencies,
          child: FavoriteTeamScope(
            controller: _favoriteTeamController!,
            child: SessionScope(
              controller: _sessionController!,
              child: Builder(
                builder: (context) {
                  return _buildApp(_router!, context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  MaterialApp _buildApp(GoRouter router, BuildContext context) {
    TeamSummary? favTeam;
    try {
      favTeam = FavoriteTeamScope.of(context).favoriteTeam;
    } catch (_) {
      // FavoriteTeamScope가 컨텍스트 상위에 없는 경우의 대비책
    }

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(accentColor: favTeam?.color),
      routerConfig: router,
    );
  }

  Future<_AppBootstrapData> _bootstrap() async {
    final dependencies = await AppDependencies.create();
    final initialFavoriteTeam = await dependencies.teamsRepository
        .getInitialFavoriteTeam();
    final favoriteTeamController = FavoriteTeamController(
      initialTeam: initialFavoriteTeam,
      toggleFavoriteTeamUseCase: ToggleFavoriteTeamUseCase(
        dependencies.teamsRepository,
      ),
    );
    final sessionController = SessionController(
      authRepository: dependencies.authRepository,
    );
    await sessionController.initialize();
    return _AppBootstrapData(
      dependencies: dependencies,
      favoriteTeamController: favoriteTeamController,
      sessionController: sessionController,
    );
  }
}

class _AppErrorScreen extends StatelessWidget {
  const _AppErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

class _AppBootstrapData {
  const _AppBootstrapData({
    required this.dependencies,
    required this.favoriteTeamController,
    required this.sessionController,
  });

  final AppDependencies dependencies;
  final FavoriteTeamController favoriteTeamController;
  final SessionController sessionController;
}
