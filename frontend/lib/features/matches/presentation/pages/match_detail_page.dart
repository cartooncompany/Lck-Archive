import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/extensions/date_extensions.dart';
import 'package:frontend/shared/models/lck_match_detail.dart';
import 'package:frontend/shared/models/lck_scheduled_match.dart';
import 'package:frontend/shared/widgets/responsive_page_container.dart';
import 'package:frontend/shared/widgets/section_header.dart';
import 'package:frontend/shared/widgets/team_logo.dart';
import 'package:frontend/shared/widgets/app_status_card.dart';

class MatchDetailPage extends StatefulWidget {
  const MatchDetailPage({required this.matchId, super.key});

  final String matchId;

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage>
    with TickerProviderStateMixin {
  LckMatchDetail? _match;
  bool _isLoading = false;
  String? _error;

  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_match == null && !_isLoading) {
      _fetchMatchDetail();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _rebuildTabController(int gameCount) {
    _tabController?.dispose();
    _tabController = TabController(length: 1 + gameCount, vsync: this);
  }

  Future<void> _fetchMatchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = AppDependenciesScope.of(context).matchesRepository;
      final match = await repository.getMatchDetail(widget.matchId);
      if (mounted) {
        _rebuildTabController(match.games.length);
        setState(() {
          _match = match;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = _match;
    final tabController = _tabController;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('경기 상세')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || match == null || tabController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('경기 상세')),
        body: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 32),
          children: [
            ResponsivePageContainer(
              maxWidth: 1040,
              child: AppStatusCard(
                title: '경기 정보를 불러오지 못했습니다.',
                message: _error ?? '데이터를 불러오는 중 오류가 발생했습니다.',
                icon: Icons.error_outline_rounded,
                actionLabel: '다시 시도',
                onActionTap: _fetchMatchDetail,
              ),
            ),
          ],
        ),
      );
    }

    final tabs = <Tab>[
      const Tab(text: '개요'),
      ...match.games.map((g) => Tab(text: '${g.sequenceNumber}세트')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${match.homeTeam.shortName} vs ${match.awayTeam.shortName}'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: tabs.length > 4,
          tabAlignment: tabs.length > 4 ? TabAlignment.start : TabAlignment.fill,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _OverviewTab(match: match, onOpenVod: _openVod),
          ...match.games.map(
            (game) => _GameTab(
              game: game,
              homeTeam: match.homeTeam,
              awayTeam: match.awayTeam,
            ),
          ),
        ],
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ─── 개요 탭 ─────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.match, required this.onOpenVod});

  final LckMatchDetail match;
  final ValueChanged<String> onOpenVod;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      children: [
        ResponsivePageContainer(
          maxWidth: 1080,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MatchHeader(match: match, onOpenVod: onOpenVod),
              const SizedBox(height: 24),
              _ParticipantsSection(match: match),
              if (match.games.isEmpty) ...[
                const SizedBox(height: 24),
                AppStatusCard(
                  title: match.status == 'SCHEDULED'
                      ? '경기 예정 상태입니다.'
                      : '세트 데이터가 없습니다.',
                  message: match.status == 'SCHEDULED'
                      ? '아직 치러지지 않은 경기입니다. 경기가 시작되면 상세 데이터가 수집됩니다.'
                      : 'GRID Series State에서 세트별 상세 정보가 수집되면 이 영역에 표시됩니다.',
                  icon: match.status == 'SCHEDULED'
                      ? Icons.schedule_rounded
                      : Icons.analytics_outlined,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 세트 탭 ─────────────────────────────────────────────────────────────────

class _GameTab extends StatelessWidget {
  const _GameTab({
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
  });

  final LckMatchGame game;
  final LckScheduledTeam homeTeam;
  final LckScheduledTeam awayTeam;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      children: [
        ResponsivePageContainer(
          maxWidth: 1080,
          child: _GameCard(
            game: game,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            initiallyExpanded: true,
          ),
        ),
      ],
    );
  }
}

// ─── 경기 헤더 ────────────────────────────────────────────────────────────────

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
        .toList(growable: false)
      ..sort((a, b) => _positionOrder(a.position).compareTo(_positionOrder(b.position)));
    final awayParticipants = match.participants
        .where((participant) => participant.team.id == match.awayTeam.id)
        .toList(growable: false)
      ..sort((a, b) => _positionOrder(a.position).compareTo(_positionOrder(b.position)));

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
  const _GameCard({
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
    this.initiallyExpanded,
  });

  final LckMatchGame game;
  final LckScheduledTeam homeTeam;
  final LckScheduledTeam awayTeam;
  final bool? initiallyExpanded;

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
          initiallyExpanded: initiallyExpanded ?? (game.sequenceNumber == 1),
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
              _DraftActionWrap(
                actions: game.draftActions,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
              ),
              const SizedBox(height: 14),
            ],
            if (game.playerStats.isEmpty)
              const AppStatusCard(
                title: '선수 스탯이 없습니다.',
                message: '세트별 선수 통계가 수집되면 이곳에 표시됩니다.',
                icon: Icons.people_outline_rounded,
                dense: true,
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
  const _DraftActionWrap({
    required this.actions,
    required this.homeTeam,
    required this.awayTeam,
  });

  final List<LckMatchDraftAction> actions;
  final LckScheduledTeam homeTeam;
  final LckScheduledTeam awayTeam;

  @override
  Widget build(BuildContext context) {
    final homeBans = actions.where((a) => a.drafterId == homeTeam.id && a.type == 'BAN').toList();
    final homePicks = actions.where((a) => a.drafterId == homeTeam.id && a.type == 'PICK').toList();
    final awayBans = actions.where((a) => a.drafterId == awayTeam.id && a.type == 'BAN').toList();
    final awayPicks = actions.where((a) => a.drafterId == awayTeam.id && a.type == 'PICK').toList();

    Widget buildBanSection(List<LckMatchDraftAction> bans) {
      if (bans.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: bans.map((ban) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block_flipped, size: 10, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  ban.draftableName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildPickSection(List<LckMatchDraftAction> picks, Color accentColor) {
      if (picks.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: picks.map((pick) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Text(
              pick.draftableName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports_outlined, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                '세트 밴픽',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homeTeam.shortName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('BAN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    buildBanSection(homeBans),
                    const SizedBox(height: 10),
                    const Text('PICK', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    buildPickSection(homePicks, AppColors.accent),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 120,
                color: AppColors.divider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      awayTeam.shortName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('BAN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    buildBanSection(awayBans),
                    const SizedBox(height: 10),
                    const Text('PICK', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    buildPickSection(awayPicks, Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}

class _PlayerStatsSection extends StatefulWidget {
  const _PlayerStatsSection({required this.stats});

  final List<LckMatchGamePlayerStat> stats;

  @override
  State<_PlayerStatsSection> createState() => _PlayerStatsSectionState();
}

class _PlayerStatsSectionState extends State<_PlayerStatsSection> {
  int _viewMode = 0; // 0: 목록, 1: 그래프
  int _metricType = 0; // 0: 딜량, 1: 골드

  String _normalizePos(String? pos) {
    if (pos == null) return '';
    final p = pos.toUpperCase();
    if (p == 'JUNGLE' || p == 'JGL' || p == 'JUG') return 'JUG';
    if (p == 'SUPPORT' || p == 'SUP') return 'SUP';
    if (p == 'MIDDLE' || p == 'MID') return 'MID';
    if (p == 'BOTTOM' || p == 'ADC') return 'ADC';
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<LckMatchGamePlayerStat>>{};
    for (final stat in widget.stats) {
      grouped
          .putIfAbsent(stat.team.id, () => <LckMatchGamePlayerStat>[])
          .add(stat);
    }

    final teamGroups = grouped.values.toList(growable: false);
    if (teamGroups.isEmpty) return const SizedBox.shrink();

    final homeStats = teamGroups[0];
    final awayStats = teamGroups.length > 1 ? teamGroups[1] : <LckMatchGamePlayerStat>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 뷰 모드 전환 토글 (커스텀 네온/다크 스타일 탭바)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _viewMode = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _viewMode == 0 ? AppColors.surfaceElevated : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          size: 15,
                          color: _viewMode == 0 ? AppColors.accent : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '상세 기록 목록',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _viewMode == 0 ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _viewMode = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _viewMode == 1 ? AppColors.surfaceElevated : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 15,
                          color: _viewMode == 1 ? AppColors.accent : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '지표 비교 그래프',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _viewMode == 1 ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_viewMode == 0)
          LayoutBuilder(
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
          )
        else ...[
          // 지표 전환 탭
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('가한 피해량 (딜량)'),
                selected: _metricType == 0,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _metricType = 0;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('획득 골드'),
                selected: _metricType == 1,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _metricType = 1;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGraphList(homeStats, awayStats),
        ],
      ],
    );
  }

  Widget _buildGraphList(
    List<LckMatchGamePlayerStat> homeStats,
    List<LckMatchGamePlayerStat> awayStats,
  ) {
    final positions = ['TOP', 'JUG', 'MID', 'ADC', 'SUP'];

    int maxVal = 1;
    for (final stat in widget.stats) {
      final val = _metricType == 0 ? (stat.damageDealt ?? 0) : (stat.totalGold ?? 0);
      if (val > maxVal) {
        maxVal = val;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _metricType == 0
                    ? Icons.local_fire_department_rounded
                    : Icons.monetization_on_rounded,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                _metricType == 0 ? '포지션별 가한 피해량(딜량)' : '포지션별 획득 골드량',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...positions.map((pos) {
            final homeStat = homeStats.firstWhere(
              (s) => _normalizePos(s.position) == pos,
              orElse: () => homeStats.first,
            );
            final awayStat = awayStats.firstWhere(
              (s) => _normalizePos(s.position) == pos,
              orElse: () => awayStats.isNotEmpty ? awayStats.first : homeStats.first,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pos,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSingleBar(homeStat, maxVal, isHome: true),
                  const SizedBox(height: 6),
                  _buildSingleBar(awayStat, maxVal, isHome: false),
                  if (pos != 'SUP') const SizedBox(height: 10),
                  if (pos != 'SUP') const Divider(height: 1, color: AppColors.divider),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSingleBar(LckMatchGamePlayerStat stat, int maxVal, {required bool isHome}) {
    final value = _metricType == 0 ? (stat.damageDealt ?? 0) : (stat.totalGold ?? 0);
    final ratio = maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    final teamColor = isHome ? AppColors.accent : const Color(0xFF607D8B);

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.playerName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (stat.championName != null)
                Text(
                  stat.championName!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * ratio,
                    height: 16,
                    decoration: BoxDecoration(
                      color: teamColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _formatNumber(value),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
          ...(List<LckMatchGamePlayerStat>.from(stats)
            ..sort((a, b) => _positionOrder(a.position ?? '').compareTo(_positionOrder(b.position ?? ''))))
            .map(
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

  String _displayPosition(String? position) {
    if (position == null) return '-';
    switch (position.toUpperCase()) {
      case 'JUNGLE':
      case 'JGL':
      case 'JUG':
        return 'JUG';
      case 'SUPPORT':
        return 'SUP';
      case 'MIDDLE':
      case 'MID':
        return 'MID';
      case 'TOP':
        return 'TOP';
      case 'ADC':
      case 'BOTTOM':
        return 'ADC';
      default:
        return position.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                _displayPosition(stat.position),
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

int _positionOrder(String? position) {
  if (position == null) return 6;
  switch (position.toUpperCase()) {
    case 'TOP':
      return 1;
    case 'JUNGLE':
    case 'JGL':
    case 'JUG':
      return 2;
    case 'MID':
    case 'MIDDLE':
      return 3;
    case 'ADC':
    case 'BOTTOM':
      return 4;
    case 'SUPPORT':
    case 'SUP':
      return 5;
    default:
      return 6;
  }
}
