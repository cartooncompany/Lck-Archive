import 'package:flutter/material.dart';

import '../../features/players/presentation/pages/player_detail_page.dart';
import '../../features/teams/presentation/pages/team_detail_page.dart';
import '../../shared/models/player_profile.dart';
import '../../shared/models/team_summary.dart';
import '../../shared/widgets/app_shell.dart';

final class AppRouter {
  static const String shell = '/';
  static const String teamDetail = '/team-detail';
  static const String playerDetail = '/player-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case teamDetail:
        final team = settings.arguments as TeamSummary;
        return MaterialPageRoute<void>(
          builder: (_) => TeamDetailPage(team: team),
          settings: settings,
        );
      case playerDetail:
        final player = settings.arguments as PlayerProfile;
        return MaterialPageRoute<void>(
          builder: (_) => PlayerDetailPage(player: player),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
    }
  }
}
