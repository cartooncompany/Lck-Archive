import 'package:flutter/material.dart';

enum AppTab { home, teams, players, news, myPage }

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
      case AppTab.myPage:
        return '마이페이지';
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
      case AppTab.myPage:
        return Icons.person_rounded;
    }
  }
}
