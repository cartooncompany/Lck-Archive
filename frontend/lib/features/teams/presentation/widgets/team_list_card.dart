import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../../../matches/presentation/widgets/form_strip.dart';

class TeamListCard extends StatelessWidget {
  const TeamListCard({required this.team, required this.onTap, super.key});

  final TeamSummary team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            TeamLogo(
              initials: team.initials,
              logoUrl: team.logoUrl,
              size: 56,
              foregroundColor: team.color,
              borderRadius: 18,
              textStyle: TextStyle(
                color: team.color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        team.rankLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${team.seasonRecord}  |  세트 ${team.setRecord}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FormStrip(form: team.recentForm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
