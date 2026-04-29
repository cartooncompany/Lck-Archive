import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/lck_match_detail.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/team_logo.dart';

class MatchDetailPage extends StatefulWidget {
  const MatchDetailPage({required this.matchId, super.key});

  final String matchId;

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  Future<LckMatchDetail>? _matchFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _matchFuture ??= AppDependenciesScope.of(
      context,
    ).matchesRepository.getMatchDetail(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('경기 상세')),
      body: FutureBuilder<LckMatchDetail>(
        future: _matchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 32),
              children: const [
                ResponsivePageContainer(
                  maxWidth: 1040,
                  child: _MessageCard(
                    title: '경기 정보를 불러오지 못했습니다.',
                    body: '잠시 후 다시 시도해 주세요.',
                  ),
                ),
              ],
            );
          }

          final match = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 32),
            children: [
              ResponsivePageContainer(
                maxWidth: 1080,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MatchHeader(match: match, onOpenVod: _openVod),
                    const SizedBox(height: 24),
                    _ParticipantsSection(match: match),
                    const SizedBox(height: 24),
                    const SectionHeader(title: '세트별 데이터'),
                    const SizedBox(height: 12),
                    if (match.games.isEmpty)
                      const _MessageCard(
                        title: '세트 데이터가 없습니다.',
                        body:
                            'GRID Series State에서 세트별 상세 정보가 수집되면 이 영역에 표시됩니다.',
                      )
                    else
                      ...match.games.map(
                        (game) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GameCard(game: game),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openVod(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _showSnackBar('유효하지 않은 VOD 링크입니다.');
      return;
    }

    try {
      final launched = await launchUrl(uri, webOnlyWindowName: '_blank');
      if (!launched) {
        _showSnackBar('VOD 링크를 열지 못했습니다.');
      }
    } catch (_) {
      _showSnackBar('VOD 링크를 열지 못했습니다.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({required this.match, required this.onOpenVod});

  final LckMatchDetail match;
  final ValueChanged<String> onOpenVod;

  @override
  Widget build(BuildContext context) {
    final note = match.note;
    final vodUrl = match.vodUrl?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Expanded(
                child: Text(
                  match.scheduledAt.toKoreanMonthDayTime(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(status: match.status),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TeamScore(
                  team: match.homeTeam,
                  score: match.score.home,
                  isWinner: match.winner?.id == match.homeTeam.id,
                  alignEnd: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  ':',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: _TeamScore(
                  team: match.awayTeam,
                  score: match.score.away,
                  isWinner: match.winner?.id == match.awayTeam.id,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (vodUrl != null && vodUrl.isNotEmpty) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onOpenVod(vodUrl),
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('VOD 보기'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({
    required this.team,
    required this.score,
    required this.isWinner,
    required this.alignEnd,
  });

  final LckScheduledTeam team;
  final int score;
  final bool isWinner;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          team.shortName,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isWinner ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          team.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );

    final logo = TeamLogo(
      initials: team.shortName,
      logoUrl: team.logoUrl,
      size: 48,
      backgroundColor: AppColors.surfaceElevated,
      borderColor: isWinner ? AppColors.accent : AppColors.divider,
      foregroundColor: AppColors.textPrimary,
      borderRadius: 16,
    );

    final scoreText = Text(
      score.toString(),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: isWinner ? AppColors.accent : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: alignEnd
          ? [
              scoreText,
              const SizedBox(width: 12),
              Flexible(child: details),
              const SizedBox(width: 10),
              logo,
            ]
          : [
              logo,
              const SizedBox(width: 10),
              Flexible(child: details),
              const SizedBox(width: 12),
              scoreText,
            ],
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({required this.match});

  final LckMatchDetail match;

  @override
  Widget build(BuildContext context) {
    if (match.participants.isEmpty) {
      return const SizedBox.shrink();
    }

    final homeParticipants = match.participants
        .where((participant) => participant.team.id == match.homeTeam.id)
        .toList(growable: false);
    final awayParticipants = match.participants
        .where((participant) => participant.team.id == match.awayTeam.id)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '출전 선수'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final home = _ParticipantTeamList(
              team: match.homeTeam,
              participants: homeParticipants,
            );
            final away = _ParticipantTeamList(
              team: match.awayTeam,
              participants: awayParticipants,
            );

            if (compact) {
              return Column(children: [home, const SizedBox(height: 12), away]);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: home),
                const SizedBox(width: 12),
                Expanded(child: away),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ParticipantTeamList extends StatelessWidget {
  const _ParticipantTeamList({required this.team, required this.participants});

  final LckScheduledTeam team;
  final List<LckMatchParticipant> participants;

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
          Row(
            children: [
              TeamLogo(
                initials: team.shortName,
                logoUrl: team.logoUrl,
                size: 34,
                backgroundColor: AppColors.surfaceElevated,
                borderColor: AppColors.divider,
                foregroundColor: AppColors.textPrimary,
                borderRadius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  team.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (participants.isEmpty)
            Text(
              '출전 선수 정보가 없습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            )
          else
            ...participants.map(
              (participant) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        participant.position,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        participant.playerName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (participant.isStarter)
                      const _SmallBadge(label: '선발')
                    else
                      const _SmallBadge(label: '교체'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final LckMatchGame game;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (game.mapName?.trim().isNotEmpty == true) game.mapName!.trim(),
      if (game.duration?.trim().isNotEmpty == true)
        _formatDuration(game.duration!),
      if (game.winner != null) '승리 ${game.winner!.shortName}',
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: game.sequenceNumber == 1,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            '${game.sequenceNumber}세트',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
          children: [
            if (game.draftActions.isNotEmpty) ...[
              _DraftActionWrap(actions: game.draftActions),
              const SizedBox(height: 14),
            ],
            if (game.playerStats.isEmpty)
              const _MessageCard(
                title: '선수 스탯이 없습니다.',
                body: '세트별 선수 통계가 수집되면 이곳에 표시됩니다.',
              )
            else
              _PlayerStatsSection(stats: game.playerStats),
          ],
        ),
      ),
    );
  }
}

class _DraftActionWrap extends StatelessWidget {
  const _DraftActionWrap({required this.actions});

  final List<LckMatchDraftAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('밴픽', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions
              .map((action) {
                final name = action.draftableName?.trim();
                final label = [
                  if (action.sequenceNumber.trim().isNotEmpty)
                    action.sequenceNumber.trim(),
                  _draftTypeLabel(action.type),
                  if (name != null && name.isNotEmpty) name,
                ].join(' ');

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _PlayerStatsSection extends StatelessWidget {
  const _PlayerStatsSection({required this.stats});

  final List<LckMatchGamePlayerStat> stats;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<LckMatchGamePlayerStat>>{};
    for (final stat in stats) {
      grouped
          .putIfAbsent(stat.team.id, () => <LckMatchGamePlayerStat>[])
          .add(stat);
    }

    final teamGroups = grouped.values.toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        if (compact) {
          return Column(
            children: teamGroups
                .map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TeamStatsGroup(stats: group),
                  ),
                )
                .toList(growable: false),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: teamGroups
              .map(
                (group) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _TeamStatsGroup(stats: group),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _TeamStatsGroup extends StatelessWidget {
  const _TeamStatsGroup({required this.stats});

  final List<LckMatchGamePlayerStat> stats;

  @override
  Widget build(BuildContext context) {
    final team = stats.first.team;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TeamLogo(
                initials: team.shortName,
                logoUrl: team.logoUrl,
                size: 30,
                backgroundColor: AppColors.surfaceElevated,
                borderColor: AppColors.divider,
                foregroundColor: AppColors.textPrimary,
                borderRadius: 10,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.shortName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...stats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlayerStatRow(stat: stat),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerStatRow extends StatelessWidget {
  const _PlayerStatRow({required this.stat});

  final LckMatchGamePlayerStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(
                stat.position ?? '-',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                stat.playerName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              stat.kdaText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          [
            if (stat.championName?.trim().isNotEmpty == true)
              stat.championName!.trim(),
            if (stat.totalGold != null) '골드 ${_formatNumber(stat.totalGold!)}',
            if (stat.damageDealt != null)
              '딜 ${_formatNumber(stat.damageDealt!)}',
            if (stat.visionScore != null)
              '시야 ${stat.visionScore!.toStringAsFixed(1)}',
            if (stat.killParticipation != null)
              'KP ${(stat.killParticipation! * 100).toStringAsFixed(0)}%',
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'COMPLETED';
    final color = isCompleted ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

String _statusLabel(String status) {
  switch (status) {
    case 'COMPLETED':
      return '경기 종료';
    case 'CANCELED':
      return '경기 취소';
    case 'LIVE':
      return '진행 중';
    default:
      return '예정';
  }
}

String _draftTypeLabel(String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('ban')) {
    return 'BAN';
  }
  if (normalized.contains('pick')) {
    return 'PICK';
  }
  return type.toUpperCase();
}

String _formatNumber(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < raw.length; index += 1) {
    final remaining = raw.length - index;
    buffer.write(raw[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _formatDuration(String duration) {
  final match = RegExp(
    r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
  ).firstMatch(duration);
  if (match == null) {
    return duration;
  }

  final hours = int.tryParse(match.group(1) ?? '') ?? 0;
  final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
  final seconds = int.tryParse(match.group(3) ?? '') ?? 0;

  if (hours > 0) {
    return '$hours시간 $minutes분';
  }
  if (minutes > 0) {
    return '$minutes분 $seconds초';
  }
  return '$seconds초';
}
