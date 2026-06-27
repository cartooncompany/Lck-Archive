import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/shared/extensions/date_extensions.dart';
import 'package:frontend/shared/models/player_profile.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/shared/widgets/player_avatar.dart';
import 'package:frontend/shared/widgets/responsive_page_container.dart';
import 'package:frontend/shared/widgets/app_status_card.dart';
import 'package:frontend/features/players/presentation/widgets/player_radar_chart.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({required this.player, super.key});

  final PlayerProfile player;

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  PlayerProfile? _player;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_player == null || _shouldFetchPlayerDetail(_player!)) {
      _fetchPlayerDetail();
    }
  }

  Future<void> _fetchPlayerDetail() async {
    setState(() => _error = null);

    try {
      final repository = AppDependenciesScope.of(context).playersRepository;
      final player = await repository.getPlayer(widget.player.id);
      if (mounted) {
        setState(() => _player = player);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _player ?? widget.player;
    final metrics = _buildMetrics(player);

    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          ResponsivePageContainer(
            maxWidth: 1040,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  AppStatusCard(
                    title: '상세 기록을 가져오지 못했습니다.',
                    message: _error ?? '통계 데이터를 최신화하는 중 오류가 발생했습니다.',
                    icon: Icons.sync_problem_rounded,
                    actionLabel: '상세 기록 다시 불러오기',
                    dense: true,
                    onActionTap: _fetchPlayerDetail,
                  ),
                  const SizedBox(height: 16),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 640;

                    Widget buildTeamButton() {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: player.teamColor.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: player.teamColor.withValues(alpha: 0.08),
                          ),
                          onPressed: () => _openTeam(context, player),
                          icon: Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: player.teamColor,
                          ),
                          label: Text(
                            '소속 팀 보기',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: player.teamColor,
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: player.teamColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: player.teamColor.withValues(alpha: 0.12),
                            blurRadius: 24,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCompact) ...[
                            Row(
                              children: [
                                PlayerAvatar(
                                  name: player.name,
                                  profileImageUrl: player.profileImageUrl,
                                  size: 80,
                                  accentColor: player.teamColor,
                                  borderRadius: 24,
                                  textStyle: TextStyle(
                                    color: player.teamColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.0,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${player.teamName}  |  ${player.position}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color:
                                                  AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: buildTeamButton(),
                            ),
                          ] else
                            Row(
                              children: [
                                PlayerAvatar(
                                  name: player.name,
                                  profileImageUrl: player.profileImageUrl,
                                  size: 84,
                                  accentColor: player.teamColor,
                                  borderRadius: 26,
                                  textStyle: TextStyle(
                                    color: player.teamColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.0,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${player.teamName}  |  ${player.position}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color:
                                                  AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      buildTeamButton(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Text(
                              player.headline,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                Text(
                  '시즌 기록',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                if (player.stats != null && player.stats!.gamesPlayed > 0) ...[
                  PlayerRadarChart(
                    stats: player.stats!,
                    accentColor: player.teamColor,
                  ),
                  const SizedBox(height: 16),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                    final aspectRatio = crossAxisCount == 1
                        ? 3.4
                        : crossAxisCount == 2
                        ? 1.35
                        : 1.45;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: metrics.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: aspectRatio,
                          ),
                      itemBuilder: (context, index) {
                        final metric = metrics[index];
                        return _StatCard(
                          label: metric.label,
                          value: metric.value,
                          accentColor: player.teamColor,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                Text(
                  '최근 경기 출전 정보',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                if (player.recentAppearances.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      '현재 API에는 선수별 최근 출전 기록이 없어 기본 정보만 표시합니다.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...player.recentAppearances.map((appearance) {
                    final isWin = appearance.result.trim() == '승';
                    final neonColor = isWin
                        ? const Color(0xFF2AD3FF)
                        : const Color(0xFFFF5A5A);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: neonColor.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: neonColor.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  appearance.playedAt.toKoreanDate(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: neonColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: neonColor.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    appearance.result,
                                    style: TextStyle(
                                      color: neonColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'vs ${appearance.opponent}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appearance.performance,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_PlayerMetric> _buildMetrics(PlayerProfile player) {
    final metrics = <_PlayerMetric>[];

    if (player.stats != null && player.stats!.gamesPlayed > 0) {
      metrics.add(_PlayerMetric(label: '출전 세트 수', value: '${player.stats!.gamesPlayed}'));
      metrics.add(_PlayerMetric(label: '평균 KDA', value: '${player.stats!.avgKda}'));
      metrics.add(_PlayerMetric(label: '통산 킬 / 데스 / 어시', value: '${player.stats!.totalKills} / ${player.stats!.totalDeaths} / ${player.stats!.totalAssists}'));
      metrics.add(_PlayerMetric(label: '평균 K / D / A', value: '${player.stats!.avgKills} / ${player.stats!.avgDeaths} / ${player.stats!.avgAssists}'));
    } else {
      metrics.add(_PlayerMetric(label: '시즌 경기 수', value: '${player.seasonMatches}'));
    }

    if (player.realName != null && player.realName!.trim().isNotEmpty) {
      metrics.add(_PlayerMetric(label: '실명', value: player.realName!));
    }
    if (player.nationality != null && player.nationality!.trim().isNotEmpty) {
      metrics.add(_PlayerMetric(label: '국적', value: player.nationality!));
    }
    if (player.birthDate != null) {
      metrics.add(
        _PlayerMetric(label: '생년월일', value: player.birthDate!.toKoreanDate()),
      );
    }

    if (metrics.isEmpty && player.keyStats.isNotEmpty) {
      metrics.addAll(
        player.keyStats.entries.map(
          (entry) => _PlayerMetric(label: entry.key, value: entry.value),
        ),
      );
    }

    if (metrics.isEmpty) {
      metrics.add(_PlayerMetric(label: '소속 팀', value: player.teamName));
      metrics.add(_PlayerMetric(label: '포지션', value: player.position));
    }

    return metrics;
  }

  bool _shouldFetchPlayerDetail(PlayerProfile player) {
    return player.realName == null &&
        player.nationality == null &&
        player.birthDate == null;
  }

  Future<void> _openTeam(BuildContext context, PlayerProfile player) async {
    final dependencies = AppDependenciesScope.of(context);

    TeamSummary? team;
    if (player.teamId.isNotEmpty) {
      try {
        team = await dependencies.teamsRepository.getTeam(player.teamId);
      } catch (_) {
        team = null;
      }
    }

    team ??= await dependencies.teamsRepository.findTeamByTag(player.teamName);

    if (!context.mounted || team == null) {
      return;
    }

    context.pushNamed(AppRouteNames.teamDetail, extra: team);
  }


}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  double? _parseProgress(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = double.tryParse(clean);
    if (num == null) return null;
    if (val.contains('%')) {
      return (num / 100).clamp(0.0, 1.0);
    }
    if (num <= 10.0) {
      return (num / 10.0).clamp(0.0, 1.0);
    }
    if (num <= 100.0) {
      return (num / 100.0).clamp(0.0, 1.0);
    }
    return (num / 1000.0).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _parseProgress(value);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: progress != null ? AppColors.accent : Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            )
          else
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor.withValues(alpha: 0.6), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerMetric {
  const _PlayerMetric({required this.label, required this.value});

  final String label;
  final String value;
}
