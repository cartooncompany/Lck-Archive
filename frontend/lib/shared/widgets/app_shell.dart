import 'package:flutter/material.dart';

import '../../core/enums/app_tab.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/players/presentation/pages/players_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import 'app_bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _currentTab = AppTab.home;

  late final List<Widget> _pages = const [
    HomePage(),
    TeamsPage(),
    PlayersPage(),
    NewsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: AppTab.values.indexOf(_currentTab),
          children: _pages,
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: _currentTab,
        onSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
