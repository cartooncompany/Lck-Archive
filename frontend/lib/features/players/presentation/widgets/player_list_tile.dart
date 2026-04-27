import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/widgets/player_avatar.dart';

class PlayerListTile extends StatelessWidget {
  const PlayerListTile({required this.player, required this.onTap, super.key});

  final PlayerProfile player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackTrailing = constraints.maxWidth < 460;

          return Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerAvatar(
                  name: player.name,
                  profileImageUrl: player.profileImageUrl,
                  size: 40,
                  accentColor: player.teamColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${player.teamName}  |  ${player.position}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        player.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (stackTrailing) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${player.seasonMatches}경기',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!stackTrailing) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${player.seasonMatches}경기',
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
