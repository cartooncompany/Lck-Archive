import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
import '../../../../shared/widgets/app_status_card.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({required this.player, super.key});

  final PlayerProfile player;

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  Future<PlayerProfile>? _playerFuture;
  bool _isGeneratingAiSummary = false;

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
                    if (snapshot.hasError) ...[
                      AppStatusCard(
                        title: '상세 기록을 가져오지 못했습니다.',
                        message: snapshot.error?.toString() ?? '통계 데이터를 최신화하는 중 오류가 발생했습니다.',
                        icon: Icons.sync_problem_rounded,
                        actionLabel: '상세 기록 다시 불러오기',
                        dense: true,
                        onActionTap: () => setState(() {
                          _playerFuture = AppDependenciesScope.of(context)
                              .playersRepository.getPlayer(widget.player.id);
                        }),
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
                    const SizedBox(height: AppSpacing.section),
                    _buildAiSummarySection(context, player),
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

  Widget _buildAiSummarySection(BuildContext context, PlayerProfile player) {
    final aiSummary = player.aiSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: player.teamColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AI 선수 분석 리포트',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withOpacity(0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: player.teamColor.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: player.teamColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isGeneratingAiSummary
              ? const Column(
                  children: [
                    SizedBox(height: 24),
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Gemini AI가 시즌 지표와 최근 경기를 기반으로\n스카우팅 리포트를 작성하고 있습니다...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                )
              : aiSummary == null || aiSummary.trim().isEmpty
                  ? Column(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '아직 생성된 AI 리포트가 없습니다.\n아래 버튼을 눌러 스카우팅 리포트를 생성해 보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: player.teamColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: RoundedRectangleBorder().borderRadius,
                              ),
                            ),
                            onPressed: () => _generateAiSummary(context, player.id),
                            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: const Text(
                              'AI 분석 요약 리포트 생성',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.copyWith(
                              bodyMedium: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                      ),
                      child: MarkdownBody(
                        data: aiSummary,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          h3: TextStyle(
                            color: player.teamColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.8,
                          ),
                          listBullet: const TextStyle(
                            color: Colors.white,
                          ),
                          blockSpacing: 12,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _generateAiSummary(BuildContext context, String playerId) async {
    setState(() {
      _isGeneratingAiSummary = true;
    });

    try {
      final repository = AppDependenciesScope.of(context).playersRepository;
      await repository.requestPlayerAiSummary(playerId);
      setState(() {
        _playerFuture = repository.getPlayer(playerId);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 리포트 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAiSummary = false;
        });
      }
    }
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
