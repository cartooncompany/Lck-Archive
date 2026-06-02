import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/responsive_page_container.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({required this.player, super.key});

  final PlayerProfile player;

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  Future<PlayerProfile>? _playerFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playerFuture ??= _shouldFetchPlayerDetail(widget.player)
        ? AppDependenciesScope.of(
            context,
          ).playersRepository.getPlayer(widget.player.id)
        : Future<PlayerProfile>.value(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: _playerFuture,
      initialData: widget.player,
      builder: (context, snapshot) {
        final player = snapshot.data ?? widget.player;
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 640;

                        Widget buildTeamButton() {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: player.teamColor.withOpacity(0.6),
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
                                backgroundColor: player.teamColor.withOpacity(
                                  0.08,
                                ),
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
                            color: AppColors.surfaceElevated.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: player.teamColor.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: player.teamColor.withOpacity(0.12),
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
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
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
                          color: AppColors.surfaceElevated.withOpacity(0.5),
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
                              color: AppColors.surface.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: neonColor.withOpacity(0.4),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: neonColor.withOpacity(0.06),
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
                                        color: neonColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: neonColor.withOpacity(0.4),
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
      },
    );
  }

  List<_PlayerMetric> _buildMetrics(PlayerProfile player) {
    final metrics = <_PlayerMetric>[
      _PlayerMetric(label: '시즌 경기 수', value: '${player.seasonMatches}'),
    ];

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

    if (metrics.length == 1 && player.keyStats.isNotEmpty) {
      metrics.addAll(
        player.keyStats.entries.map(
          (entry) => _PlayerMetric(label: entry.key, value: entry.value),
        ),
      );
    }

    if (metrics.length == 1) {
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
        color: AppColors.surfaceElevated.withOpacity(0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
                  colors: [accentColor.withOpacity(0.6), Colors.transparent],
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
