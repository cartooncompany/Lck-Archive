import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/player_avatar.dart';

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
    _playerFuture ??=
        _shouldFetchPlayerDetail(widget.player)
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              8,
              AppSpacing.screen,
              32,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PlayerAvatar(
                          name: player.name,
                          profileImageUrl: player.profileImageUrl,
                          size: 72,
                          accentColor: player.teamColor,
                          borderRadius: 22,
                          textStyle: TextStyle(
                            color: player.teamColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${player.teamName}  |  ${player.position}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.tonalIcon(
                                onPressed: () => _openTeam(context, player),
                                icon: const Icon(Icons.shield_rounded),
                                label: const Text('소속 팀 보기'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      player.headline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Text('시즌 기록', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: metrics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return _StatCard(label: metric.label, value: metric.value);
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    '현재 API에는 선수별 최근 출전 기록이 없어 기본 정보만 표시합니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...player.recentAppearances.map(
                  (appearance) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                appearance.playedAt.toKoreanDate(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                appearance.result,
                                style: TextStyle(
                                  color: appearance.result == '승'
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'vs ${appearance.opponent}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appearance.performance,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
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

    Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
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
