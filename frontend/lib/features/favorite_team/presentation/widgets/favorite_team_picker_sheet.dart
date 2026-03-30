import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../shared/models/team_summary.dart';
import '../bloc/favorite_team_controller.dart';

class FavoriteTeamPickerSheet extends StatelessWidget {
  const FavoriteTeamPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavoriteTeamScope.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('응원팀 선택', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '홈 화면과 뉴스 우선순위가 즉시 변경됩니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ...MockLckData.teams.map(
              (team) => _FavoriteTeamTile(
                team: team,
                isSelected: team.id == controller.favoriteTeam.id,
                onTap: () {
                  controller.selectTeam(team);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTeamTile extends StatelessWidget {
  const _FavoriteTeamTile({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  final TeamSummary team;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: AppColors.surface,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: team.color.withValues(alpha: 0.18),
          foregroundColor: team.color,
          child: Text(team.initials),
        ),
        title: Text(team.name),
        subtitle: Text('${team.rank}위  |  ${team.seasonRecord}'),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
            : null,
      ),
    );
  }
}
