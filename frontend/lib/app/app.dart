import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/mock_lck_data.dart';
import '../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../shared/models/team_summary.dart';
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

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  @override
  void dispose() {
    _favoriteTeamController?.dispose();
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
          return _buildApp(const _AppLoadingScreen());
        }

        final bootstrapData = snapshot.data;
        final dependencies = bootstrapData?.dependencies;
        _favoriteTeamController ??= FavoriteTeamController(
          initialTeam:
              bootstrapData?.initialFavoriteTeam ?? MockLckData.defaultFavoriteTeam,
        );

        return AppDependenciesScope(
          dependencies: dependencies!,
          child: FavoriteTeamScope(
            controller: _favoriteTeamController!,
            child: _buildApp(),
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
      home: home,
      initialRoute: home == null ? AppRouter.shell : null,
      onGenerateRoute: home == null ? AppRouter.onGenerateRoute : null,
    );
  }

  Future<_AppBootstrapData> _bootstrap() async {
    final dependencies = await AppDependencies.create();
    final initialFavoriteTeam = await dependencies.teamsRepository
        .getInitialFavoriteTeam();
    return _AppBootstrapData(
      dependencies: dependencies,
      initialFavoriteTeam: initialFavoriteTeam,
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AppErrorScreen extends StatelessWidget {
  const _AppErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message, textAlign: TextAlign.center)));
  }
}

class _AppBootstrapData {
  const _AppBootstrapData({
    required this.dependencies,
    required this.initialFavoriteTeam,
  });

  final AppDependencies dependencies;
  final TeamSummary initialFavoriteTeam;
}
