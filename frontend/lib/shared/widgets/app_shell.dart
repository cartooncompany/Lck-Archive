import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/enums/app_tab.dart';
import '../../core/constants/app_strings.dart';
import '../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
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
  static const double _webNavigationBreakpoint = 960;

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
    if (_useWebNavigation(context)) {
      return _WebAppShell(
        currentTab: _currentTab,
        pages: _pages,
        onSelected: (tab) => setState(() => _currentTab = tab),
      );
    }

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

  bool _useWebNavigation(BuildContext context) {
    return kIsWeb && MediaQuery.sizeOf(context).width >= _webNavigationBreakpoint;
  }
}

class _WebAppShell extends StatelessWidget {
  const _WebAppShell({
    required this.currentTab,
    required this.pages,
    required this.onSelected,
  });

  final AppTab currentTab;
  final List<Widget> pages;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 288,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: favoriteTeam.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: favoriteTeam.color.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '응원팀',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          favoriteTeam.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${favoriteTeam.rank}위  |  ${favoriteTeam.seasonRecord}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: AppTab.values.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tab = AppTab.values[index];
                        return _WebNavItem(
                          tab: tab,
                          isSelected: tab == currentTab,
                          onTap: () => onSelected(tab),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Web navigation',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: IndexedStack(
                      index: AppTab.values.indexOf(currentTab),
                      children: pages,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebNavItem extends StatelessWidget {
  const _WebNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final AppTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Material(
      color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(tab.icon, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tab.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
