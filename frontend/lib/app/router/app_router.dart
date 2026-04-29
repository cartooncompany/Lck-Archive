import 'package:flutter/material.dart';

import '../../features/matches/presentation/pages/match_detail_page.dart';
import '../../features/matches/presentation/pages/matches_schedule_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/players/presentation/pages/player_detail_page.dart';
import '../../features/teams/presentation/pages/team_detail_page.dart';
import '../../shared/models/player_profile.dart';
import '../../shared/models/team_summary.dart';
import '../../shared/widgets/app_shell.dart';

final class AppRouter {
  static const String shell = '/';
  static const String matchesSchedule = '/matches-schedule';
  static const String matchDetail = '/match-detail';
  static const String settings = '/settings';
  static const String teamDetail = '/team-detail';
  static const String playerDetail = '/player-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case matchesSchedule:
        return MaterialPageRoute<void>(
          builder: (_) => const MatchesSchedulePage(),
          settings: settings,
        );
      case matchDetail:
        final matchId = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => MatchDetailPage(matchId: matchId),
          settings: settings,
        );
      case AppRouter.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsPage(),
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
