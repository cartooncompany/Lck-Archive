import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/core/enums/app_tab.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/my_page/presentation/pages/my_page_page.dart';
import 'package:frontend/features/news/presentation/pages/news_page.dart';
import 'package:frontend/features/players/presentation/pages/players_page.dart';
import 'package:frontend/features/teams/presentation/pages/teams_page.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'app_bottom_nav_bar.dart';
import 'responsive_page_container.dart';
import 'team_logo.dart';

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
    MyPagePage(),
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
    return kIsWeb &&
        MediaQuery.sizeOf(context).width >= _webNavigationBreakpoint;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useExpandedMargins =
                constraints.maxWidth >= AppResponsiveBreakpoints.wide;
            final shellMargin = useExpandedMargins ? 24.0 : 16.0;
            final navigationWidth = useExpandedMargins ? 288.0 : 252.0;

            return Padding(
              padding: EdgeInsets.all(shellMargin),
              child: Row(
                children: [
                  SizedBox(
                    width: navigationWidth,
                    child: _WebSidebar(
                      currentTab: currentTab,
                      favoriteTeam: favoriteTeam,
                      onSelected: onSelected,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.glassBorderMuted),
                        ),
                        child: Column(
                          children: [
                            _WebContentHeader(currentTab: currentTab),
                            const Divider(height: 1),
                            Expanded(
                              child: IndexedStack(
                                index: AppTab.values.indexOf(currentTab),
                                children: pages,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({
    required this.currentTab,
    required this.favoriteTeam,
    required this.onSelected,
  });

  final AppTab currentTab;
  final TeamSummary? favoriteTeam;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = this.favoriteTeam;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppColors.primaryGradient,
              ).createShader(bounds),
              child: Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: favoriteTeam != null
                      ? [
                          favoriteTeam.color.withValues(alpha: 0.15),
                          favoriteTeam.color.withValues(alpha: 0.03),
                        ]
                      : AppColors.darkGlassGradient,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (favoriteTeam?.color ?? AppColors.accent).withValues(
                    alpha: favoriteTeam != null ? 0.35 : 0.12,
                  ),
                  width: favoriteTeam != null ? 1.2 : 1.0,
                ),
                boxShadow: favoriteTeam != null
                    ? AppColors.neonGlow(
                        color: favoriteTeam.color,
                        blurRadius: 6,
                      )
                    : null,
              ),
              child: favoriteTeam == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY TEAM',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아직 선택하지 않음',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '설정에서 응원팀을 선택하면 대시보드와 뉴스가 개인화됩니다.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                height: 1.35,
                              ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY TEAM',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: favoriteTeam.color.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            TeamLogo(
                              initials: favoriteTeam.initials,
                              logoUrl: favoriteTeam.logoUrl,
                              size: 44,
                              foregroundColor: favoriteTeam.color,
                              borderRadius: 14,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    favoriteTeam.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${favoriteTeam.rankLabel}  |  ${favoriteTeam.seasonRecord}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          ],
        ),
      ),
    );
  }
}

class _WebContentHeader extends StatelessWidget {
  const _WebContentHeader({required this.currentTab});

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTab.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0x1A2AD3FF), Color(0x055A7CFF)],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    tab.icon,
                    color: isSelected ? AppColors.accent : foregroundColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tab.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : foregroundColor,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
