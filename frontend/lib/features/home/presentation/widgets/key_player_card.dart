import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/widgets/player_avatar.dart';

class KeyPlayerCard extends StatelessWidget {
  const KeyPlayerCard({required this.player, required this.onTap, super.key});

  final PlayerProfile player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlayerAvatar(
                    name: player.name,
                    profileImageUrl: player.profileImageUrl,
                    size: 42,
                    accentColor: player.teamColor,
                    borderRadius: 14,
                  ),
                  const Spacer(),
                  Text(
                    player.position,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(player.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                player.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '시즌 경기 ${player.seasonMatches}',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
