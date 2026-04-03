import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/auth/presentation/bloc/session_controller.dart';
import '../features/auth/presentation/pages/session_gate.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
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
            _AppErrorScreen(message: '앱 초기화 중 오류가 발생했습니다.\n${snapshot.error}'),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return _buildApp(const SplashPage());
        }

        final bootstrapData = snapshot.data!;
        final dependencies = bootstrapData.dependencies;
        _favoriteTeamController ??= bootstrapData.favoriteTeamController;
        _sessionController ??= bootstrapData.sessionController;

        return AppDependenciesScope(
          dependencies: dependencies,
          child: FavoriteTeamScope(
            controller: _favoriteTeamController!,
            child: SessionScope(
              controller: _sessionController!,
              child: _buildApp(),
            ),
          ),
        );
      },
    );
  }

  MaterialApp _buildApp([Widget? home]) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: home ?? const SessionGate(),
      onGenerateRoute: home == null ? AppRouter.onGenerateRoute : null,
    );
  }

  Future<_AppBootstrapData> _bootstrap() async {
    final dependencies = await AppDependencies.create();
    final initialFavoriteTeam = await dependencies.teamsRepository
        .getInitialFavoriteTeam();
    final favoriteTeamController = FavoriteTeamController(
      initialTeam: initialFavoriteTeam,
      onChanged: (team) =>
          dependencies.teamsRepository.saveFavoriteTeamId(team.id),
    );
    final sessionController = SessionController(
      authRepository: dependencies.authRepository,
    );
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
