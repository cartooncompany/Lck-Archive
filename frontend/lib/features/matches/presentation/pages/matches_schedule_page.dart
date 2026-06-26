import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/app_status_card.dart';
import '../utils/match_prediction_storage.dart';
import '../widgets/scheduled_match_tile.dart';

class MatchesSchedulePage extends StatefulWidget {
  const MatchesSchedulePage({super.key});

  @override
  State<MatchesSchedulePage> createState() => _MatchesSchedulePageState();
}

class _MatchesSchedulePageState extends State<MatchesSchedulePage>
    with SingleTickerProviderStateMixin {
  int _weekOffset = 0;
  Future<List<LckScheduledMatch>>? _matchesFuture;
  bool _hasLoadedPredictions = false;
  Map<String, String> _matchPredictions = <String, String>{};
  late final AnimationController _skeletonController;

  ({DateTime start, DateTime end}) get _currentWeekRange =>
      _weekRangeForOffset(_weekOffset);

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
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _matchesFuture ??= _loadSchedule();

    if (_hasLoadedPredictions) return;
    _hasLoadedPredictions = true;
    unawaited(_loadPredictions());
  }

  @override
  Widget build(BuildContext context) {
    final range = _currentWeekRange;

    return Scaffold(
      appBar: AppBar(
        title: Text(_weekOffset == 0 ? '이번 주 경기 일정' : '경기 일정'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSchedule,
        child: FutureBuilder<List<LckScheduledMatch>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            final matches = snapshot.data ?? const <LckScheduledMatch>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                matches.isEmpty) {
              return Column(
                children: [
                  _WeekNavigator(
                    weekOffset: _weekOffset,
                    range: range,
                    onPrev: _goToPrevWeek,
                    onNext: _goToNextWeek,
                    onReset: _weekOffset != 0 ? _goToCurrentWeek : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: _ScheduleSkeleton(animation: _skeletonController),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError && matches.isEmpty) {
              final errorMsg =
                  snapshot.error?.toString() ?? '일정을 불러오는 중 오류가 발생했습니다.';
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  _WeekNavigator(
                    weekOffset: _weekOffset,
                    range: range,
                    onPrev: _goToPrevWeek,
                    onNext: _goToNextWeek,
                    onReset: _weekOffset != 0 ? _goToCurrentWeek : null,
                  ),
                  ResponsivePageContainer(
                    maxWidth: 1040,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AppStatusCard(
                        title: '경기 일정을 불러오지 못했습니다.',
                        message: errorMsg,
                        icon: Icons.error_outline_rounded,
                        actionLabel: '새로고침 시도',
                        onActionTap: _refreshSchedule,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (matches.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  _WeekNavigator(
                    weekOffset: _weekOffset,
                    range: range,
                    onPrev: _goToPrevWeek,
                    onNext: _goToNextWeek,
                    onReset: _weekOffset != 0 ? _goToCurrentWeek : null,
                  ),
                  const ResponsivePageContainer(
                    maxWidth: 1040,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: AppStatusCard(
                        title: '이 주에 예정된 경기가 없습니다.',
                        message: '다른 주를 선택하거나 새 일정이 등록될 때까지 기다려 주세요.',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ),
                ],
              );
            }

            final groupedMatches = _groupMatchesByDay(matches);
            final dayEntries = groupedMatches.entries.toList()
              ..sort((l, r) => l.key.compareTo(r.key));

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _WeekNavigator(
                  weekOffset: _weekOffset,
                  range: range,
                  onPrev: _goToPrevWeek,
                  onNext: _goToNextWeek,
                  onReset: _weekOffset != 0 ? _goToCurrentWeek : null,
                ),
                ResponsivePageContainer(
                  maxWidth: 1040,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const SectionHeader(title: '요일별 경기 일정'),
                      const SizedBox(height: 8),
                      Text(
                        '날짜별로 모아서 볼 수 있습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...dayEntries.expand((entry) {
                        return [
                          _ScheduleDayHeader(
                            date: entry.key,
                            count: entry.value.length,
                          ),
                          const SizedBox(height: 14),
                          ...entry.value.map(
                            (match) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ScheduledMatchTile(
                                match: match,
                                predictedWinnerTeamId:
                                    _matchPredictions[match.id],
                                onPredictWinner: (teamId) =>
                                    _handleMatchPrediction(
                                  matchId: match.id,
                                  teamId: teamId,
                                ),
                                onOpenDetail: () =>
                                    _openMatchDetail(context, match.id),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ({DateTime start, DateTime end}) _weekRangeForOffset(int offset) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: offset * 7));
    final sunday = DateTime(
      monday.year,
      monday.month,
      monday.day,
      23,
      59,
      59,
    ).add(const Duration(days: 6));
    return (start: monday, end: sunday);
  }

  Future<List<LckScheduledMatch>> _loadSchedule() async {
    final range = _currentWeekRange;
    final dependencies = AppDependenciesScope.of(context);
    final matches = await dependencies.matchesRepository.getScheduledMatches(
      from: range.start.toUtc(),
      to: range.end.toUtc(),
    );

    return matches.where((match) {
      final local = match.scheduledAt.toLocal();
      return !local.isBefore(range.start) && !local.isAfter(range.end);
    }).toList();
  }

  Future<void> _refreshSchedule() async {
    final future = _loadSchedule();
    setState(() {
      _matchesFuture = future;
    });
    await future;
  }

  void _goToPrevWeek() => setState(() {
        _weekOffset--;
        _matchesFuture = _loadSchedule();
      });

  void _goToNextWeek() => setState(() {
        _weekOffset++;
        _matchesFuture = _loadSchedule();
      });

  void _goToCurrentWeek() => setState(() {
        _weekOffset = 0;
        _matchesFuture = _loadSchedule();
      });

  Future<void> _loadPredictions() async {
    final storage = AppDependenciesScope.of(context).localStorage;
    final predictions = await loadMatchPredictions(storage);
    if (!mounted) return;
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

  Map<DateTime, List<LckScheduledMatch>> _groupMatchesByDay(
    List<LckScheduledMatch> matches,
  ) {
    final grouped = <DateTime, List<LckScheduledMatch>>{};

    for (final match in matches) {
      final local = match.scheduledAt.toLocal();
      final key = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(key, () => <LckScheduledMatch>[]).add(match);
    }

    for (final entry in grouped.values) {
      entry.sort((l, r) => l.scheduledAt.compareTo(r.scheduledAt));
    }

    return grouped;
  }

  void _openMatchDetail(BuildContext context, String matchId) {
    context.pushNamed(AppRouteNames.matchDetail, extra: matchId);
  }
}

// ─── 주간 네비게이터 ──────────────────────────────────────────────────────────

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weekOffset,
    required this.range,
    required this.onPrev,
    required this.onNext,
    this.onReset,
  });

  final int weekOffset;
  final ({DateTime start, DateTime end}) range;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final label = _rangeLabel(range.start, range.end);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
            tooltip: '이전 주',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                if (weekOffset == 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '이번 주',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onReset != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onReset,
                    child: Text(
                      '이번 주로 이동',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            tooltip: '다음 주',
          ),
        ],
      ),
    );
  }

  String _rangeLabel(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${start.year}.${_d(start.month)}.${_d(start.day)} – ${_d(end.day)}';
    }
    if (start.year == end.year) {
      return '${start.year}.${_d(start.month)}.${_d(start.day)} – ${_d(end.month)}.${_d(end.day)}';
    }
    return '${start.year}.${_d(start.month)}.${_d(start.day)} – ${end.year}.${_d(end.month)}.${_d(end.day)}';
  }

  String _d(int v) => v.toString().padLeft(2, '0');
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _ScheduleSkeleton extends AnimatedWidget {
  const _ScheduleSkeleton({required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final shimmer = Color.lerp(AppColors.surfaceElevated, AppColors.surfaceMuted, t)!;
    final headerShimmer = Color.lerp(AppColors.surfaceMuted, AppColors.surfaceElevated, t)!;

    Widget dayHeader() => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 14),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: headerShimmer,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 22,
                decoration: BoxDecoration(
                  color: headerShimmer,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );

    Widget matchCard({double widthFactor = 1.0}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: Container(
              height: 158,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.glassBorder),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dayHeader(),
        matchCard(),
        matchCard(widthFactor: 0.95),
        const SizedBox(height: 12),
        dayHeader(),
        matchCard(),
      ],
    );
  }
}

// ─── 요일 헤더 ────────────────────────────────────────────────────────────────

class _ScheduleDayHeader extends StatelessWidget {
  const _ScheduleDayHeader({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayLabel(date.weekday);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final dayColor = isWeekend ? AppColors.danger : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [dayColor, dayColor.withValues(alpha: 0.3)],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: AppColors.neonGlow(color: dayColor, blurRadius: 4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${date.month}.${date.day}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($weekday)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: dayColor.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.divider, Colors.transparent],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: dayColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Text(
              '$count경기',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: dayColor,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      default:
        return '일';
    }
  }
}
