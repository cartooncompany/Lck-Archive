import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../widgets/team_list_card.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  String _query = '';
  Future<List<TeamSummary>>? _teamsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _teamsFuture ??= _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeamSummary>>(
      future: _teamsFuture,
      builder: (context, snapshot) {
        final teams = snapshot.data ?? const <TeamSummary>[];

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            12,
            AppSpacing.screen,
            120,
          ),
          children: [
            Text('LCK 팀', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '순위, 전적, 최근 흐름을 빠르게 비교할 수 있습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            AppSearchField(
              hintText: '팀명으로 검색',
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                  _teamsFuture = _loadTeams();
                });
              },
            ),
            const SizedBox(height: 18),
            if (snapshot.connectionState == ConnectionState.waiting &&
                teams.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (teams.isEmpty)
              _TeamsMessage(message: '검색 결과가 없습니다.')
            else
              ...teams.map(
                (team) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TeamListCard(
                    team: team,
                    onTap: () => _openTeam(context, team),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<List<TeamSummary>> _loadTeams() {
    return AppDependenciesScope.of(
      context,
    ).teamsRepository.getTeams(keyword: _query);
  }

  void _openTeam(BuildContext context, TeamSummary team) {
    Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
  }
}

class _TeamsMessage extends StatelessWidget {
  const _TeamsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
