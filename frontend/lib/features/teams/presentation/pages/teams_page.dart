import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/mock_lck_data.dart';
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

  @override
  Widget build(BuildContext context) {
    final filteredTeams = MockLckData.teams.where((team) {
      final keyword = _query.toLowerCase();
      return team.name.toLowerCase().contains(keyword) ||
          team.initials.toLowerCase().contains(keyword);
    }).toList();

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
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 18),
        ...filteredTeams.map(
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
  }

  void _openTeam(BuildContext context, TeamSummary team) {
    Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
  }
}
