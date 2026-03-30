import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/mock_lck_data.dart';
import '../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LckArchiveApp extends StatefulWidget {
  const LckArchiveApp({super.key});

  @override
  State<LckArchiveApp> createState() => _LckArchiveAppState();
}

class _LckArchiveAppState extends State<LckArchiveApp> {
  late final FavoriteTeamController _favoriteTeamController;

  @override
  void initState() {
    super.initState();
    _favoriteTeamController = FavoriteTeamController(
      initialTeam: MockLckData.defaultFavoriteTeam,
    );
  }

  @override
  void dispose() {
    _favoriteTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FavoriteTeamScope(
      controller: _favoriteTeamController,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        initialRoute: AppRouter.shell,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
