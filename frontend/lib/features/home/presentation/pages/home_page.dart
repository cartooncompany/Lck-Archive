import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../shared/models/news_article.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../matches/presentation/widgets/match_result_tile.dart';
import '../../../matches/presentation/widgets/scheduled_match_tile.dart';
import '../widgets/favorite_team_card.dart';
import '../widgets/headline_news_card.dart';
import '../widgets/key_player_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<_HomePageData>? _homeFuture;
  String? _loadedTeamId;
  bool _isSyncingSchedule = false;

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
        final keyPlayers = data?.keyPlayers ?? const <PlayerProfile>[];
        final featuredNews =
            data?.featuredNews ??
            MockLckData.newsForTeamName(
              team.name,
              shortName: team.initials,
            ).take(3).toList();
        final scheduledMatches =
            data?.scheduledMatches ?? const <LckScheduledMatch>[];
        final scheduleError = data?.scheduleError;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            12,
            AppSpacing.screen,
            120,
          ),
          children: [
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.appTagline,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            FavoriteTeamCard(
              team: team,
              onTap: () => _openTeamDetail(context, team),
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: '응원팀 최근 경기 결과'),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting &&
                team.recentMatches.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (team.recentMatches.isEmpty)
              _EmptySectionMessage(message: '최근 경기 기록이 아직 없습니다.')
            else
              ...team.recentMatches
                  .take(2)
                  .map(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MatchResultTile(
                        match: match,
                        accentColor: team.color,
                      ),
                    ),
                  ),
            const SizedBox(height: AppSpacing.section - 4),
            SectionHeader(
              title: '예정 경기 일정',
              actionLabel: '새로고침',
              onActionTap: () => _refreshHomeData(context),
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
                message: '표시할 예정 경기가 없습니다. 일정 데이터가 비어 있다면 동기화를 먼저 요청해 주세요.',
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
                      child: ScheduledMatchTile(match: match),
                    ),
                  ),
            const SizedBox(height: AppSpacing.section - 4),
            const SectionHeader(title: '응원팀 주요 선수'),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting &&
                keyPlayers.isEmpty)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (keyPlayers.isEmpty)
              _EmptySectionMessage(message: '표시할 선수 정보가 없습니다.')
            else
              SizedBox(
                height: 208,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: keyPlayers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final player = keyPlayers[index];
                    return KeyPlayerCard(
                      player: player,
                      onTap: () => _openPlayerDetail(context, player),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: '이번 주 주요 뉴스'),
            const SizedBox(height: 14),
            ...featuredNews.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HeadlineNewsCard(
                  article: article,
                  onTagTap: (tag) => _handleTagTap(context, tag),
                  onSourceTap: () => _showSourceLink(context, article),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<_HomePageData> _loadHomeData(
    BuildContext context,
    TeamSummary favoriteTeam,
  ) async {
    final dependencies = AppDependenciesScope.of(context);
    final teamFuture = dependencies.teamsRepository.getTeam(favoriteTeam.id);
    final playersFuture = dependencies.playersRepository.getPlayers(
      teamId: favoriteTeam.id,
    );
    final scheduledMatchesFuture = dependencies.matchesRepository
        .getScheduledMatches(from: DateTime.now().toUtc());

    final team = await teamFuture;
    final players = await playersFuture;
    List<LckScheduledMatch> scheduledMatches = const [];
    String? scheduleError;

    try {
      scheduledMatches = await scheduledMatchesFuture;
    } on AppFailure catch (error) {
      scheduleError = error.message;
    } catch (_) {
      scheduleError = '예정 경기 일정을 불러오지 못했습니다.';
    }

    return _HomePageData(
      team: team,
      keyPlayers: players.take(3).toList(),
      featuredNews: MockLckData.newsForTeamName(
        team.name,
        shortName: team.initials,
      ).take(3).toList(),
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

  void _openPlayerDetail(BuildContext context, PlayerProfile player) {
    Navigator.of(context).pushNamed(AppRouter.playerDetail, arguments: player);
  }

  Future<void> _handleTagTap(BuildContext context, String tag) async {
    final dependencies = AppDependenciesScope.of(context);
    final team = await dependencies.teamsRepository.findTeamByTag(tag);
    if (team != null) {
      if (!context.mounted) {
        return;
      }
      _openTeamDetail(context, team);
      return;
    }

    final player = await dependencies.playersRepository.findPlayerByTag(tag);
    if (player != null) {
      if (!context.mounted) {
        return;
      }
      _openPlayerDetail(context, player);
    }
  }

  void _showSourceLink(BuildContext context, NewsArticle article) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('원문 링크 예시: ${article.link}')));
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
}

class _HomePageData {
  const _HomePageData({
    required this.team,
    required this.keyPlayers,
    required this.featuredNews,
    required this.scheduledMatches,
    required this.scheduleError,
  });

  final TeamSummary team;
  final List<PlayerProfile> keyPlayers;
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
