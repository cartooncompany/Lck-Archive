import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/enums/app_tab.dart';
import '../../core/constants/app_strings.dart';
import '../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/my_page/presentation/pages/my_page_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/players/presentation/pages/players_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
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
  bool _isWebSidebarOpen = false;

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
        isSidebarOpen: _isWebSidebarOpen,
        onToggleSidebar: () {
          setState(() {
            _isWebSidebarOpen = !_isWebSidebarOpen;
          });
        },
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
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  final AppTab currentTab;
  final List<Widget> pages;
  final ValueChanged<AppTab> onSelected;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

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

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(shellMargin),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          _WebContentHeader(
                            currentTab: currentTab,
                            isSidebarOpen: isSidebarOpen,
                            onToggleSidebar: onToggleSidebar,
                          ),
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
                Positioned(
                  left: shellMargin,
                  top: shellMargin,
                  bottom: shellMargin,
                  width: navigationWidth,
                  child: IgnorePointer(
                    ignoring: !isSidebarOpen,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      offset: isSidebarOpen
                          ? Offset.zero
                          : const Offset(-1.08, 0),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: isSidebarOpen ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.divider),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.24),
                                blurRadius: 26,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppStrings.appName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '사이드바 닫기',
                                    onPressed: onToggleSidebar,
                                    icon: const Icon(Icons.menu_open_rounded),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.appTagline,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      (favoriteTeam?.color ??
                                              AppColors.surfaceMuted)
                                          .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        (favoriteTeam?.color ??
                                                AppColors.divider)
                                            .withValues(alpha: 0.24),
                                  ),
                                ),
                                child: favoriteTeam == null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '응원팀',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '아직 선택하지 않음',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '설정에서 응원팀을 선택하면 홈과 뉴스가 개인화됩니다.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '응원팀',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              TeamLogo(
                                                initials: favoriteTeam.initials,
                                                logoUrl: favoriteTeam.logoUrl,
                                                size: 40,
                                                foregroundColor:
                                                    favoriteTeam.color,
                                                borderRadius: 14,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      favoriteTeam.name,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${favoriteTeam.rankLabel}  |  ${favoriteTeam.seasonRecord}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .textSecondary,
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
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WebContentHeader extends StatelessWidget {
  const _WebContentHeader({
    required this.currentTab,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  final AppTab currentTab;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 18, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: isSidebarOpen ? '사이드바 닫기' : '사이드바 열기',
            onPressed: onToggleSidebar,
            icon: Icon(
              isSidebarOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTab.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '메뉴 버튼으로 사이드바를 열고 닫을 수 있습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: foregroundColor),
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
