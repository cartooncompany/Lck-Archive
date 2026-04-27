import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/models/news_article.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/utils/news_article_launcher.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../matches/presentation/utils/match_prediction_storage.dart';
import '../../../matches/presentation/widgets/scheduled_match_tile.dart';
import '../../../teams/presentation/widgets/team_list_card.dart';
import '../widgets/favorite_team_card.dart';
import '../widgets/headline_news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<_HomePageData>? _homeFuture;
  String? _loadedTeamId;
  bool _isSyncingSchedule = false;
  bool _showAllStandings = false;
  bool _hasLoadedPredictions = false;
  Map<String, String> _matchPredictions = <String, String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedPredictions) {
      return;
    }
    _hasLoadedPredictions = true;
    unawaited(_loadMatchPredictions(context));
  }

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    if (_loadedTeamId != favoriteTeam.id || _homeFuture == null) {
      _loadedTeamId = favoriteTeam.id;
      _homeFuture = _loadHomeData(context, favoriteTeam);
    }

    return FutureBuilder<_HomePageData>(
      future: _homeFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final team = data?.team ?? favoriteTeam;
        final standings = data?.standings ?? const <TeamSummary>[];
        final visibleStandings = _showAllStandings
            ? standings
            : standings.take(5).toList();
        final featuredNews = data?.featuredNews ?? const <NewsArticle>[];
        final scheduledMatches =
            data?.scheduledMatches ?? const <LckScheduledMatch>[];
        final scheduleError = data?.scheduleError;

        return ListView(
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
                      const SizedBox(height: 22),
                      FavoriteTeamCard(
                        team: team,
                        onTap: () => _openTeamDetail(context, team),
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
                                  _buildScheduleSection(
                                    context: context,
                                    snapshot: snapshot,
                                    scheduledMatches: scheduledMatches,
                                    scheduleError: scheduleError,
                                  ),
                                  const SizedBox(height: AppSpacing.section),
                                  _buildStandingsSection(
                                    context: context,
                                    snapshot: snapshot,
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
                                snapshot: snapshot,
                                featuredNews: featuredNews,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildScheduleSection(
                          context: context,
                          snapshot: snapshot,
                          scheduledMatches: scheduledMatches,
                          scheduleError: scheduleError,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _buildStandingsSection(
                          context: context,
                          snapshot: snapshot,
                          standings: standings,
                          visibleStandings: visibleStandings,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        _buildNewsSection(
                          context: context,
                          snapshot: snapshot,
                          featuredNews: featuredNews,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleSection({
    required BuildContext context,
    required AsyncSnapshot<_HomePageData> snapshot,
    required List<LckScheduledMatch> scheduledMatches,
    required String? scheduleError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '경기 일정',
          actionLabel: '더 보기',
          onActionTap: () => _openSchedulePage(context),
        ),
        const SizedBox(height: 14),
        if (snapshot.connectionState == ConnectionState.waiting &&
            scheduledMatches.isEmpty &&
            scheduleError == null)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (scheduledMatches.isEmpty && scheduleError != null)
          _EmptySectionMessage(
            message: scheduleError,
            actionLabel: '다시 시도',
            onActionTap: () => _refreshHomeData(context),
          )
        else if (scheduledMatches.isEmpty)
          _EmptySectionMessage(
            message: '표시할 경기 일정이 없습니다. 일정 데이터가 비어 있다면 동기화를 먼저 요청해 주세요.',
            actionLabel: _isSyncingSchedule ? '동기화 요청 중...' : '동기화 요청',
            onActionTap: _isSyncingSchedule
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
                    predictedWinnerTeamId: _matchPredictions[match.id],
                    onPredictWinner: (teamId) => _handleMatchPrediction(
                      matchId: match.id,
                      teamId: teamId,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildStandingsSection({
    required BuildContext context,
    required AsyncSnapshot<_HomePageData> snapshot,
    required List<TeamSummary> standings,
    required List<TeamSummary> visibleStandings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '팀 순위'),
        const SizedBox(height: 14),
        if (snapshot.connectionState == ConnectionState.waiting &&
            standings.isEmpty)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
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
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSection({
    required BuildContext context,
    required AsyncSnapshot<_HomePageData> snapshot,
    required List<NewsArticle> featuredNews,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '이번 주 주요 뉴스'),
        const SizedBox(height: 14),
        if (snapshot.connectionState == ConnectionState.waiting &&
            featuredNews.isEmpty)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
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

  Future<_HomePageData> _loadHomeData(
    BuildContext context,
    TeamSummary favoriteTeam,
  ) async {
    final dependencies = AppDependenciesScope.of(context);
    final teamFuture = dependencies.teamsRepository.getTeam(favoriteTeam.id);
    final standingsFuture = dependencies.teamsRepository.getTeams();
    final featuredNewsFuture = dependencies.newsRepository
        .getFeaturedNewsForTeam(
          teamName: favoriteTeam.name,
          shortName: favoriteTeam.initials,
          limit: 3,
        );
    final scheduledMatchesFuture = dependencies.matchesRepository
        .getScheduledMatches(from: DateTime.now().toUtc());

    final team = await teamFuture;
    final standings = await standingsFuture
      ..sort((left, right) {
        if (left.rank == 0 && right.rank == 0) {
          return left.name.compareTo(right.name);
        }
        if (left.rank == 0) {
          return 1;
        }
        if (right.rank == 0) {
          return -1;
        }
        return left.rank.compareTo(right.rank);
      });
    final featuredNews = await featuredNewsFuture;
    List<LckScheduledMatch> scheduledMatches = const [];
    String? scheduleError;

    try {
      scheduledMatches = await scheduledMatchesFuture;
    } on AppFailure catch (error) {
      scheduleError = error.message;
    } catch (_) {
      scheduleError = '경기 일정을 불러오지 못했습니다.';
    }

    return _HomePageData(
      team: team,
      standings: standings,
      featuredNews: featuredNews,
      scheduledMatches: scheduledMatches,
      scheduleError: scheduleError,
    );
  }

  void _refreshHomeData(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    setState(() {
      _loadedTeamId = favoriteTeam.id;
      _homeFuture = _loadHomeData(context, favoriteTeam);
    });
  }

  void _openTeamDetail(BuildContext context, TeamSummary team) {
    Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
  }

  Future<void> _openNewsArticle(BuildContext context, NewsArticle article) {
    return openNewsArticle(context, article);
  }

  Future<void> _requestScheduleSync(BuildContext context) async {
    if (_isSyncingSchedule) {
      return;
    }

    setState(() {
      _isSyncingSchedule = true;
    });

    final dependencies = AppDependenciesScope.of(context);

    try {
      await dependencies.matchesRepository.requestLckSync();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LCK 일정 동기화를 요청했습니다. 잠시 후 새로고침해 주세요.')),
      );
      _refreshHomeData(context);
    } on AppFailure catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('동기화 요청 중 오류가 발생했습니다.')));
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingSchedule = false;
        });
      }
    }
  }

  Future<void> _loadMatchPredictions(BuildContext context) async {
    final storage = AppDependenciesScope.of(context).localStorage;
    final predictions = await loadMatchPredictions(storage);
    if (!mounted) {
      return;
    }
    setState(() {
      _matchPredictions = predictions;
    });
  }

  Future<void> _handleMatchPrediction({
    required String matchId,
    required String teamId,
  }) async {
    final currentTeamId = _matchPredictions[matchId];
    final nextPredictions = <String, String>{..._matchPredictions};

    if (currentTeamId == teamId) {
      nextPredictions.remove(matchId);
    } else {
      nextPredictions[matchId] = teamId;
    }

    setState(() {
      _matchPredictions = nextPredictions;
    });

    final storage = AppDependenciesScope.of(context).localStorage;
    await saveMatchPredictions(storage, nextPredictions);
  }

  void _openSchedulePage(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.matchesSchedule);
  }
}

class _HomePageData {
  const _HomePageData({
    required this.team,
    required this.standings,
    required this.featuredNews,
    required this.scheduledMatches,
    required this.scheduleError,
  });

  final TeamSummary team;
  final List<TeamSummary> standings;
  final List<NewsArticle> featuredNews;
  final List<LckScheduledMatch> scheduledMatches;
  final String? scheduleError;
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
