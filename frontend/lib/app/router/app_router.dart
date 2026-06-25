import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/session_controller.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/matches/presentation/pages/match_detail_page.dart';
import '../../features/matches/presentation/pages/matches_schedule_page.dart';
import '../../features/players/presentation/pages/player_detail_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/teams/presentation/pages/team_detail_page.dart';
import '../../shared/models/player_profile.dart';
import '../../shared/models/team_summary.dart';
import '../../shared/widgets/app_shell.dart';

final class AppRoutePaths {
  const AppRoutePaths._();

  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/app';
  static const String matchesSchedule = '/matches-schedule';
  static const String matchDetail = '/match-detail';
  static const String settings = '/settings';
  static const String teamDetail = '/team-detail';
  static const String playerDetail = '/player-detail';
}

final class AppRouteNames {
  const AppRouteNames._();

  static const String landing = 'landing';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String matchesSchedule = 'matchesSchedule';
  static const String matchDetail = 'matchDetail';
  static const String settings = 'settings';
  static const String teamDetail = 'teamDetail';
  static const String playerDetail = 'playerDetail';
}

final class AppRouter {
  const AppRouter._();

  static const String shell = AppRoutePaths.home;
  static const String matchesSchedule = AppRoutePaths.matchesSchedule;
  static const String matchDetail = AppRoutePaths.matchDetail;
  static const String settings = AppRoutePaths.settings;
  static const String teamDetail = AppRoutePaths.teamDetail;
  static const String playerDetail = AppRoutePaths.playerDetail;

  static GoRouter singlePageRouter(Widget page) {
    return GoRouter(
      initialLocation: AppRoutePaths.landing,
      routes: [
        GoRoute(
          path: AppRoutePaths.landing,
          name: AppRouteNames.landing,
          builder: (context, state) => page,
        ),
      ],
    );
  }

  static GoRouter createRouter({required SessionController sessionController}) {
    return GoRouter(
      initialLocation: AppRoutePaths.landing,
      refreshListenable: sessionController,
      redirect: (context, state) {
        final path = state.uri.path;
        final isPublicRoute = _publicPaths.contains(path);
        final isAuthenticated = sessionController.isAuthenticated;

        if (!isAuthenticated && !isPublicRoute) {
          return AppRoutePaths.landing;
        }

        if (isAuthenticated &&
            (path == AppRoutePaths.login || path == AppRoutePaths.signup)) {
          return AppRoutePaths.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutePaths.landing,
          name: AppRouteNames.landing,
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: AppRoutePaths.login,
          name: AppRouteNames.login,
          builder: (context, state) {
            final fromSettings = state.extra == 'fromSettings' ||
                state.uri.queryParameters['fromSettings'] == 'true';
            return LoginPage(fromSettings: fromSettings);
          },
        ),
        GoRoute(
          path: AppRoutePaths.signup,
          name: AppRouteNames.signup,
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: AppRoutePaths.home,
          name: AppRouteNames.home,
          builder: (context, state) => const AppShell(),
        ),
        GoRoute(
          path: AppRoutePaths.matchesSchedule,
          name: AppRouteNames.matchesSchedule,
          builder: (context, state) => const MatchesSchedulePage(),
        ),
        GoRoute(
          path: AppRoutePaths.matchDetail,
          name: AppRouteNames.matchDetail,
          builder: (context, state) {
            final matchId = state.extra;
            if (matchId is String) {
              return MatchDetailPage(matchId: matchId);
            }
            return const _MissingRouteDataPage(title: '경기 정보를 열 수 없습니다.');
          },
        ),
        GoRoute(
          path: AppRoutePaths.settings,
          name: AppRouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutePaths.teamDetail,
          name: AppRouteNames.teamDetail,
          builder: (context, state) {
            final team = state.extra;
            if (team is TeamSummary) {
              return TeamDetailPage(team: team);
            }
            return const _MissingRouteDataPage(title: '팀 정보를 열 수 없습니다.');
          },
        ),
        GoRoute(
          path: AppRoutePaths.playerDetail,
          name: AppRouteNames.playerDetail,
          builder: (context, state) {
            final player = state.extra;
            if (player is PlayerProfile) {
              return PlayerDetailPage(player: player);
            }
            return const _MissingRouteDataPage(title: '선수 정보를 열 수 없습니다.');
          },
        ),
      ],
      errorBuilder: (context, state) => _MissingRouteDataPage(
        title: '페이지를 찾을 수 없습니다.',
        message: state.uri.path,
      ),
    );
  }

  static const Set<String> _publicPaths = {
    AppRoutePaths.landing,
    AppRoutePaths.login,
    AppRoutePaths.signup,
  };
}

class _MissingRouteDataPage extends StatelessWidget {
  const _MissingRouteDataPage({required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LCK Archive')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(message!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => context.go(AppRoutePaths.home),
                child: const Text('홈으로 이동'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
