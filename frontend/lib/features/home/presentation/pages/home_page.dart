import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/favorite_team/presentation/widgets/favorite_team_picker_sheet.dart';
import 'package:frontend/shared/models/lck_match_detail.dart';
import 'package:frontend/shared/models/lck_scheduled_match.dart';
import 'package:frontend/shared/models/news_article.dart';
import 'package:frontend/features/matches/presentation/widgets/completed_match_tile.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/shared/utils/news_article_launcher.dart';
import 'package:frontend/shared/widgets/bounce_tap_target.dart';
import 'package:frontend/shared/widgets/responsive_page_container.dart';
import 'package:frontend/shared/widgets/section_header.dart';
import 'package:frontend/features/matches/presentation/widgets/scheduled_match_tile.dart';
import 'package:frontend/features/home/presentation/bloc/home_view_model.dart';
import 'package:frontend/shared/widgets/login_require_dialog.dart';
import 'package:frontend/features/teams/presentation/widgets/team_list_card.dart';
import 'package:frontend/features/home/presentation/widgets/favorite_team_card.dart';
import 'package:frontend/features/home/presentation/widgets/headline_news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  HomeViewModel? _viewModel;
  bool _showAllStandings = false;
  bool _hasInitialized = false;

  late final AnimationController _skeletonController;

  @override
  void initState() {
    super.initState();
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    _viewModel?.removeListener(_onViewModelChanged);
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;

    final dependencies = AppDependenciesScope.of(context);
    _viewModel = HomeViewModel(
      dependencies: dependencies,
      localStorage: dependencies.localStorage,
    )..addListener(_onViewModelChanged);
    unawaited(_viewModel!.refreshPredictions());
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const SizedBox.shrink();
    }

    final isSignedIn = SessionScope.maybeOf(context)?.isSignedIn ?? false;
    final favoriteTeam = isSignedIn
        ? FavoriteTeamScope.of(context).favoriteTeam
        : null;
    viewModel.loadIfNeeded(favoriteTeam);

    final isLoading = viewModel.isLoading;
    final data = viewModel.state;
    final team = data.team ?? favoriteTeam;
    final standings = data.standings;
    final visibleStandings = _showAllStandings
        ? standings
        : standings.take(5).toList();
    final featuredNews = data.featuredNews;
    final scheduledMatches = data.scheduledMatches;
    final scheduleError = data.scheduleError;

    return Stack(
      children: [
        // 응원팀 시그니처 색상을 반영한 은은한 구단 컬러 오라(Glow) 백그라운드
        if (team != null)
          Positioned(
            top: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      team.color.withValues(alpha: 0.16),
                      team.color.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

        ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 120),
          children: [
            ResponsivePageContainer(
              maxWidth: 1220,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useSplitLayout = constraints.maxWidth >= 1080;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, team),
                      const SizedBox(height: 22),
                      if (team != null)
                        FavoriteTeamCard(
                          team: team,
                          onTap: () => _openTeamDetail(context, team),
                        )
                      else
                        _FavoriteTeamEmptyCard(
                          onTap: () {
                            if (!isSignedIn) {
                              LoginRequireDialog.show(context);
                            } else {
                              _showFavoriteTeamPicker(context);
                            }
                          },
                        ),
                      const SizedBox(height: AppSpacing.section),
                      if (useSplitLayout)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRecentResultsSection(
                                    context: context,
                                    isLoading: isLoading,
                                    recentResults: data.recentResults,
                                    recentResultsError: data.recentResultsError,
                                  ),
                                  const SizedBox(height: AppSpacing.section),
                                  _buildScheduleSection(
                                    context: context,
                                    isLoading: isLoading,
                                    scheduledMatches: scheduledMatches,
                                    scheduleError: scheduleError,
                                  ),
                                  const SizedBox(height: AppSpacing.section),
                                  _buildStandingsSection(
                                    context: context,
                                    isLoading: isLoading,
                                    standings: standings,
                                    visibleStandings: visibleStandings,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 10,
                              child: _buildNewsSection(
                                context: context,
                                isLoading: isLoading,
                                featuredNews: featuredNews,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildRecentResultsSection(
                          context: context,
                          isLoading: isLoading,
                          recentResults: data.recentResults,
                          recentResultsError: data.recentResultsError,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _buildScheduleSection(
                          context: context,
                          isLoading: isLoading,
                          scheduledMatches: scheduledMatches,
                          scheduleError: scheduleError,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _buildStandingsSection(
                          context: context,
                          isLoading: isLoading,
                          standings: standings,
                          visibleStandings: visibleStandings,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _buildNewsSection(
                          context: context,
                          isLoading: isLoading,
                          featuredNews: featuredNews,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TeamSummary? favoriteTeam) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final dateString = '${now.month}월 ${now.day}일 LCK 라이브 리포트';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.5),
                AppColors.surfaceElevated.withValues(alpha: 0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ).createShader(bounds),
                    child: Text(
                      AppStrings.appName.toUpperCase(),
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (favoriteTeam != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: favoriteTeam.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: favoriteTeam.color.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        '${favoriteTeam.name} FAN',
                        style: textTheme.labelSmall?.copyWith(
                          color: favoriteTeam.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.appTagline,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentResultsSection({
    required BuildContext context,
    required bool isLoading,
    required List<LckMatchDetail> recentResults,
    required String? recentResultsError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '최근 경기 결과',
        ),
        const SizedBox(height: 14),
        if (isLoading && recentResults.isEmpty && recentResultsError == null)
          _SkeletonSection(animation: _skeletonController, itemCount: 3, itemHeight: 72)
        else if (recentResults.isEmpty && recentResultsError != null)
          _EmptySectionMessage(
            message: recentResultsError,
            actionLabel: '다시 시도',
            onActionTap: _refreshHomeData,
          )
        else if (recentResults.isEmpty)
          const _EmptySectionMessage(
            message: '표시할 최근 경기 결과가 없습니다.',
          )
        else
          ...recentResults.map(
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CompletedMatchTile(
                match: match,
                onOpenDetail: () => _openMatchDetail(context, match.id),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleSection({
    required BuildContext context,
    required bool isLoading,
    required List<LckScheduledMatch> scheduledMatches,
    required String? scheduleError,
  }) {
    final isSyncingSchedule = _viewModel?.isSyncingSchedule ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '경기 일정',
          actionLabel: '더 보기',
          onActionTap: () => _openSchedulePage(context),
        ),
        const SizedBox(height: 14),
        if (isLoading && scheduledMatches.isEmpty && scheduleError == null)
          _SkeletonSection(animation: _skeletonController, itemCount: 4, itemHeight: 80)
        else if (scheduledMatches.isEmpty && scheduleError != null)
          _EmptySectionMessage(
            message: scheduleError,
            actionLabel: '다시 시도',
            onActionTap: _refreshHomeData,
          )
        else if (scheduledMatches.isEmpty)
          _EmptySectionMessage(
            message: '표시할 경기 일정이 없습니다. 일정 데이터가 비어 있다면 동기화를 먼저 요청해 주세요.',
            actionLabel: isSyncingSchedule ? '동기화 요청 중...' : '동기화 요청',
            onActionTap: isSyncingSchedule
                ? null
                : () => _requestScheduleSync(context),
          )
        else
          ...scheduledMatches
              .take(4)
              .map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScheduledMatchTile(
                    match: match,
                    predictedWinnerTeamId:
                        _viewModel?.matchPredictions[match.id],
                    onPredictWinner: (teamId) => _handleMatchPrediction(
                      matchId: match.id,
                      teamId: teamId,
                    ),
                    onOpenDetail: () => _openMatchDetail(context, match.id),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildStandingsSection({
    required BuildContext context,
    required bool isLoading,
    required List<TeamSummary> standings,
    required List<TeamSummary> visibleStandings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '팀 순위'),
        const SizedBox(height: 14),
        if (isLoading && standings.isEmpty)
          _SkeletonSection(animation: _skeletonController, itemCount: 5, itemHeight: 64)
        else if (standings.isEmpty)
          const _EmptySectionMessage(message: '표시할 팀 순위가 없습니다.')
        else
          ...visibleStandings.map(
            (standingTeam) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TeamListCard(
                team: standingTeam,
                onTap: () => _openTeamDetail(context, standingTeam),
              ),
            ),
          ),
        if (standings.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllStandings = !_showAllStandings;
                  });
                },
                child: Text(
                  _showAllStandings ? '접기' : '더 보기',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSection({
    required BuildContext context,
    required bool isLoading,
    required List<NewsArticle> featuredNews,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '이번 주 주요 뉴스'),
        const SizedBox(height: 14),
        if (isLoading && featuredNews.isEmpty)
          _SkeletonSection(animation: _skeletonController, itemCount: 3, itemHeight: 88)
        else if (featuredNews.isEmpty)
          const _EmptySectionMessage(
            message: '표시할 뉴스가 없습니다. 뉴스 데이터가 비어 있다면 백엔드에서 동기화를 먼저 요청해 주세요.',
          )
        else
          ...featuredNews.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HeadlineNewsCard(
                article: article,
                onTap: () => _openNewsArticle(context, article),
              ),
            ),
          ),
      ],
    );
  }

  TeamSummary? get _currentFavoriteTeam {
    final isSignedIn = SessionScope.maybeOf(context)?.isSignedIn ?? false;
    return isSignedIn ? FavoriteTeamScope.of(context).favoriteTeam : null;
  }

  void _refreshHomeData() {
    unawaited(_viewModel?.load(_currentFavoriteTeam) ?? Future<void>.value());
  }

  void _openTeamDetail(BuildContext context, TeamSummary team) {
    context.pushNamed(AppRouteNames.teamDetail, extra: team);
  }

  Future<void> _openNewsArticle(BuildContext context, NewsArticle article) {
    return openNewsArticle(context, article);
  }

  Future<void> _showFavoriteTeamPicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FavoriteTeamPickerSheet(),
    );
  }

  Future<void> _requestScheduleSync(BuildContext context) async {
    final viewModel = _viewModel;
    if (viewModel == null || viewModel.isSyncingSchedule) {
      return;
    }

    final message = await viewModel.requestScheduleSync(_currentFavoriteTeam);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleMatchPrediction({
    required String matchId,
    required String teamId,
  }) async {
    await _viewModel?.toggleMatchPrediction(matchId: matchId, teamId: teamId);
  }

  void _openSchedulePage(BuildContext context) {
    context.pushNamed(AppRouteNames.matchesSchedule);
  }

  void _openMatchDetail(BuildContext context, String matchId) {
    context.pushNamed(AppRouteNames.matchDetail, extra: matchId);
  }
}


class _FavoriteTeamEmptyCard extends StatelessWidget {
  const _FavoriteTeamEmptyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.65),
                AppColors.surfaceElevated.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.glassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.03),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  '응원팀',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '아직 선택하지 않았습니다.',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '나만의 LCK 아카이브를 활성화하세요! 응원팀을 선택하면 전적 홈 분석 보드와 관련 주요 뉴스가 취향에 맞춰 개인화됩니다.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              BounceTapTarget(
                onTap: onTap,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.neonGlow(
                      color: AppColors.accent,
                      blurRadius: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.background,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '응원팀 선택하기',
                        style: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _SkeletonSection extends AnimatedWidget {
  const _SkeletonSection({
    required Animation<double> animation,
    required this.itemCount,
    required this.itemHeight,
  }) : super(listenable: animation);

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final shimmerColor = Color.lerp(
      AppColors.surfaceElevated,
      AppColors.surfaceMuted,
      t,
    )!;

    return Column(
      children: List.generate(itemCount, (i) {
        // 각 카드의 너비를 살짝 다르게 해서 자연스럽게
        final widthFactor = i % 2 == 0 ? 1.0 : 0.88;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  const _EmptySectionMessage({
    required this.message,
    this.actionLabel,
    this.onActionTap,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontSize: 13.5,
                ),
              ),
              if (actionLabel != null && onActionTap != null) ...[
                const SizedBox(height: 14),
                BounceTapTarget(
                  onTap: onActionTap!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
