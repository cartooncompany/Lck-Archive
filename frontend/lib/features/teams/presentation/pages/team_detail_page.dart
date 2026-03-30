import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/team_logo.dart';
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
        final isFavorite = favoriteController.favoriteTeam.id == team.id;

        return Scaffold(
          appBar: AppBar(title: Text(team.name)),
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
                  gradient: LinearGradient(
                    colors: [
                      team.color.withValues(alpha: 0.92),
                      Color.lerp(team.color, AppColors.background, 0.72)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TeamLogo(
                          initials: team.initials,
                          logoUrl: team.logoUrl,
                          size: 64,
                          foregroundColor: Colors.white,
                          borderColor: Colors.white24,
                          borderRadius: 20,
                          textStyle: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.14),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => favoriteController.selectTeam(team),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          ),
                          label: Text(isFavorite ? '응원팀' : '응원팀 설정'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      team.rankLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.name,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      team.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _InfoMetric(label: '시즌 전적', value: team.seasonRecord),
                        const SizedBox(width: 24),
                        _InfoMetric(label: '세트 득실', value: team.setRecord),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '최근 5경기 흐름',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (team.recentForm.isEmpty)
                      const Text(
                        '아직 최근 흐름 데이터가 없습니다.',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      FormStrip(form: team.recentForm),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Text('최근 경기 결과', style: Theme.of(context).textTheme.titleLarge),
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
                    child: MatchResultTile(match: match, accentColor: team.color),
                  ),
                ),
              const SizedBox(height: AppSpacing.section - 4),
              Text('소속 선수', style: Theme.of(context).textTheme.titleLarge),
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
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRouter.playerDetail, arguments: player),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
