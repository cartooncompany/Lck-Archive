import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../bloc/favorite_team_controller.dart';

class FavoriteTeamPickerSheet extends StatelessWidget {
  const FavoriteTeamPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavoriteTeamScope.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;
    final teamsFuture = AppDependenciesScope.of(context).teamsRepository.getTeams();

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('응원팀 선택', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '홈 화면과 뉴스 우선순위가 즉시 변경됩니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: FutureBuilder<List<TeamSummary>>(
                  future: teamsFuture,
                  builder: (context, snapshot) {
                    final teams = snapshot.data ?? const <TeamSummary>[];

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        teams.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (teams.isEmpty) {
                      return const Center(child: Text('응원팀 목록이 없습니다.'));
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: teams.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return _FavoriteTeamTile(
                          team: team,
                          isSelected: team.id == controller.favoriteTeam.id,
                          onTap: () {
                            controller.selectTeam(team);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      onTap: onTap,
      leading: TeamLogo(
        initials: team.initials,
        logoUrl: team.logoUrl,
        size: 40,
        foregroundColor: team.color,
        borderRadius: 999,
      ),
      title: Text(team.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${team.rankLabel}  |  ${team.seasonRecord}'),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
          : null,
    );
  }
}
