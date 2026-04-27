import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../../shared/widgets/section_header.dart';
import '../utils/match_prediction_storage.dart';
import '../widgets/scheduled_match_tile.dart';

class MatchesSchedulePage extends StatefulWidget {
  const MatchesSchedulePage({super.key});

  @override
  State<MatchesSchedulePage> createState() => _MatchesSchedulePageState();
}

class _MatchesSchedulePageState extends State<MatchesSchedulePage> {
  Future<List<LckScheduledMatch>>? _matchesFuture;
  bool _hasLoadedPredictions = false;
  Map<String, String> _matchPredictions = <String, String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _matchesFuture ??= _loadSchedule();

    if (_hasLoadedPredictions) {
      return;
    }
    _hasLoadedPredictions = true;
    unawaited(_loadPredictions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1주 경기 일정')),
      body: RefreshIndicator(
        onRefresh: _refreshSchedule,
        child: FutureBuilder<List<LckScheduledMatch>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            final matches = snapshot.data ?? const <LckScheduledMatch>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                matches.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && matches.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 20, bottom: 32),
                children: const [
                  ResponsivePageContainer(
                    maxWidth: 1040,
                    child: _ScheduleMessageCard(
                      title: '경기 일정을 불러오지 못했습니다.',
                      body: '아래로 당겨 새로고침하거나 잠시 후 다시 시도해 주세요.',
                    ),
                  ),
                ],
              );
            }

            if (matches.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 20, bottom: 32),
                children: const [
                  ResponsivePageContainer(
                    maxWidth: 1040,
                    child: _ScheduleMessageCard(
                      title: '1주 안에 예정된 경기가 없습니다.',
                      body: '새 일정이 등록되면 이 화면에 요일별로 정리됩니다.',
                    ),
                  ),
                ],
              );
            }

            final groupedMatches = _groupMatchesByDay(matches);
            final dayEntries = groupedMatches.entries.toList()
              ..sort((left, right) => left.key.compareTo(right.key));

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 32),
              children: [
                ResponsivePageContainer(
                  maxWidth: 1040,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: '요일별 경기 일정'),
                      const SizedBox(height: 8),
                      Text(
                        '오늘부터 1주 동안 열리는 경기를 날짜별로 모아서 볼 수 있습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...dayEntries.expand((entry) {
                        final sectionChildren = <Widget>[
                          _ScheduleDayHeader(
                            date: entry.key,
                            count: entry.value.length,
                          ),
                          const SizedBox(height: 12),
                        ];

                        sectionChildren.addAll(
                          entry.value.map(
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
                              ),
                            ),
                          ),
                        );
                        sectionChildren.add(const SizedBox(height: 8));
                        return sectionChildren;
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

  Future<List<LckScheduledMatch>> _loadSchedule() async {
    final now = DateTime.now();
    final rangeEnd = now.add(const Duration(days: 7));
    final dependencies = AppDependenciesScope.of(context);
    final matches = await dependencies.matchesRepository.getScheduledMatches(
      from: now.toUtc(),
      to: rangeEnd.toUtc(),
    );

    return matches.where((match) {
      final scheduledAt = match.scheduledAt.toLocal();
      return !scheduledAt.isBefore(now) && !scheduledAt.isAfter(rangeEnd);
    }).toList();
  }

  Future<void> _refreshSchedule() async {
    final future = _loadSchedule();
    setState(() {
      _matchesFuture = future;
    });
    await future;
  }

  Future<void> _loadPredictions() async {
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
      entry.sort(
        (left, right) => left.scheduledAt.compareTo(right.scheduledAt),
      );
    }

    return grouped;
  }
}

class _ScheduleDayHeader extends StatelessWidget {
  const _ScheduleDayHeader({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayLabel(date.weekday);

    return Row(
      children: [
        Text(
          '${date.month}.${date.day} ($weekday)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            '$count경기',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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

class _ScheduleMessageCard extends StatelessWidget {
  const _ScheduleMessageCard({required this.title, required this.body});

  final String title;
  final String body;

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
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
