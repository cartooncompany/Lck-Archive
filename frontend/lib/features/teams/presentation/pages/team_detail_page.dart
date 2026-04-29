import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/media_url_resolver.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../matches/presentation/widgets/form_strip.dart';
import '../../../matches/presentation/widgets/match_result_tile.dart';

class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({required this.team, super.key});

  final TeamSummary team;

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Future<_TeamDetailData>? _detailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detailFuture ??= _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteController = FavoriteTeamScope.of(context);
    return FutureBuilder<_TeamDetailData>(
      future: _detailFuture,
      initialData: _TeamDetailData(team: widget.team, players: const []),
      builder: (context, snapshot) {
        final team = snapshot.data?.team ?? widget.team;
        final players = snapshot.data?.players ?? const <PlayerProfile>[];
        final isFavorite = favoriteController.favoriteTeam?.id == team.id;
        final resolvedLogoUrl = resolveMediaUrl(team.logoUrl);

        return Scaffold(
          appBar: AppBar(title: Text(team.name)),
          body: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              ResponsivePageContainer(
                maxWidth: 1080,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 640;

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _buildDetailStartColor(team),
                                _buildDetailEndColor(team),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: ExcludeSemantics(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Opacity(
                                          opacity: 0.18,
                                          child: resolvedLogoUrl != null
                                              ? Image.network(
                                                  resolvedLogoUrl,
                                                  width: 280,
                                                  height: 280,
                                                  fit: BoxFit.contain,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                  errorBuilder: (_, _, _) =>
                                                      _TeamBackgroundMonogram(
                                                        initials: team.initials,
                                                      ),
                                                )
                                              : _TeamBackgroundMonogram(
                                                  initials: team.initials,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: ExcludeSemantics(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                              Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.42, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isCompact) ...[
                                        Text(
                                          team.rankLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 12),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.14),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => favoriteController
                                              .selectTeam(team),
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                          ),
                                          label: Text(
                                            isFavorite ? '응원팀' : '응원팀 설정',
                                          ),
                                        ),
                                      ] else
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.rankLabel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                            ),
                                            const Spacer(),
                                            FilledButton.icon(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white
                                                    .withValues(alpha: 0.14),
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  favoriteController.selectTeam(
                                                    team,
                                                  ),
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_border_rounded,
                                              ),
                                              label: Text(
                                                isFavorite ? '응원팀' : '응원팀 설정',
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 18),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 420,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(
                                                    fontSize: isCompact
                                                        ? 34
                                                        : 40,
                                                    height: 0.96,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -1.2,
                                                  ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              team.summary,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.88,
                                                        ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _HeroInfoMetric(
                                              label: '시즌 전적',
                                              value: team.seasonRecord,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _HeroInfoMetric(
                                              label: '세트 득실',
                                              value: team.setRecord,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '최근 5경기 흐름',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 10),
                                      if (team.recentForm.isEmpty)
                                        const Text(
                                          '아직 최근 흐름 데이터가 없습니다.',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        )
                                      else
                                        FormStrip(form: team.recentForm),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Text(
                      '최근 경기 결과',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        team.recentMatches.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (team.recentMatches.isEmpty)
                      const _DetailMessage(message: '최근 경기 결과가 없습니다.')
                    else
                      ...team.recentMatches.map(
                        (match) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MatchResultTile(
                            match: match,
                            accentColor: team.color,
                            onTap: match.id == null
                                ? null
                                : () => _openMatchDetail(context, match.id!),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.section - 4),
                    Text(
                      '소속 선수',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        players.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (players.isEmpty)
                      const _DetailMessage(message: '소속 선수 정보가 없습니다.')
                    else
                      ...players.map(
                        (player) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlayerRow(
                            player: player,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRouter.playerDetail,
                              arguments: player,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMatchDetail(BuildContext context, String matchId) {
    Navigator.of(context).pushNamed(AppRouter.matchDetail, arguments: matchId);
  }

  Future<_TeamDetailData> _loadDetail() async {
    final dependencies = AppDependenciesScope.of(context);
    final teamFuture = dependencies.teamsRepository.getTeam(widget.team.id);
    final playersFuture = dependencies.playersRepository.getPlayers(
      teamId: widget.team.id,
    );

    final team = await teamFuture;
    final players = await playersFuture;
    return _TeamDetailData(team: team, players: players);
  }

  Color _buildDetailStartColor(TeamSummary team) {
    if (_isT1Team(team)) {
      return const Color(0xFFC4382E);
    }

    return team.color.withValues(alpha: 0.92);
  }

  Color _buildDetailEndColor(TeamSummary team) {
    if (_isT1Team(team)) {
      return const Color(0xFF681E19);
    }

    return Color.lerp(team.color, AppColors.background, 0.72)!;
  }

  bool _isT1Team(TeamSummary team) {
    final normalizedName = team.name.trim().toUpperCase();
    final normalizedInitials = team.initials.trim().toUpperCase();
    return normalizedName == 'T1' || normalizedInitials == 'T1';
  }
}

class _HeroInfoMetric extends StatelessWidget {
  const _HeroInfoMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TeamDetailData {
  const _TeamDetailData({required this.team, required this.players});

  final TeamSummary team;
  final List<PlayerProfile> players;
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.onTap});

  final PlayerProfile player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: PlayerAvatar(
        name: player.name,
        profileImageUrl: player.profileImageUrl,
        size: 40,
        accentColor: player.teamColor,
      ),
      title: Text(player.name),
      subtitle: Text('${player.position}  |  시즌 ${player.seasonMatches}경기'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _TeamBackgroundMonogram extends StatelessWidget {
  const _TeamBackgroundMonogram({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontSize: 160,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -5,
      ),
    );
  }
}
