import 'package:flutter/material.dart';

enum AppTab { home, teams, players, news, settings }

extension AppTabX on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return '홈';
      case AppTab.teams:
        return '팀';
      case AppTab.players:
        return '선수';
      case AppTab.news:
        return '뉴스';
      case AppTab.settings:
        return '설정';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home_rounded;
      case AppTab.teams:
        return Icons.shield_rounded;
      case AppTab.players:
        return Icons.person_search_rounded;
      case AppTab.news:
        return Icons.feed_rounded;
      case AppTab.settings:
        return Icons.settings_rounded;
    }
  }
}
