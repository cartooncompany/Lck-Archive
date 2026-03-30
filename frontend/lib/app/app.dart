import 'package:flutter/material.dart';

import 'app_dependencies.dart';
import 'app_dependencies_scope.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/mock_lck_data.dart';
import '../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../shared/models/team_summary.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LckArchiveApp extends StatefulWidget {
  const LckArchiveApp({super.key});

  @override
  State<LckArchiveApp> createState() => _LckArchiveAppState();
}

class _LckArchiveAppState extends State<LckArchiveApp> {
  late final AppDependencies _dependencies;
  late final Future<TeamSummary> _bootstrapFuture;
  FavoriteTeamController? _favoriteTeamController;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies.create();
    _bootstrapFuture = _dependencies.teamsRepository.getInitialFavoriteTeam();
  }

  @override
  void dispose() {
    _favoriteTeamController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeamSummary>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildApp(const _AppLoadingScreen());
        }

        _favoriteTeamController ??= FavoriteTeamController(
          initialTeam: snapshot.data ?? MockLckData.defaultFavoriteTeam,
        );

        return AppDependenciesScope(
          dependencies: _dependencies,
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
