import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/models/player_profile.dart';
import 'package:frontend/shared/widgets/player_avatar.dart';

class PlayerListTile extends StatefulWidget {
  const PlayerListTile({required this.player, required this.onTap, super.key});

  final PlayerProfile player;
  final VoidCallback onTap;

  @override
  State<PlayerListTile> createState() => _PlayerListTileState();
}

class _PlayerListTileState extends State<PlayerListTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  Widget _buildPositionBadge(BuildContext context, String position) {
    final pos = position.trim().toUpperCase();
    Color badgeColor;
    IconData icon;
    String label = pos;

    switch (pos) {
      case 'TOP':
        badgeColor = const Color(0xFFFF5A5A);
        icon = Icons.shield_outlined;
        break;
      case 'JGL':
      case 'JUG':
      case 'JUNGLE':
        badgeColor = const Color(0xFF4EAD5B);
        icon = Icons.forest_outlined;
        label = 'JUG';
        break;
      case 'MID':
        badgeColor = const Color(0xFFFFD32A);
        icon = Icons.bolt_outlined;
        break;
      case 'ADC':
      case 'BOT':
        badgeColor = const Color(0xFF2AD3FF);
        icon = Icons.gps_fixed_outlined;
        label = 'ADC';
        break;
      case 'SUP':
      case 'SUPPORT':
        badgeColor = const Color(0xFFFF7BBF);
        icon = Icons.favorite_border_outlined;
        label = 'SUP';
        break;
      default:
        badgeColor = AppColors.accent;
        icon = Icons.star_border_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final teamColor = player.teamColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _isHovered ? -4.0 : 0.0, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceElevated.withOpacity(0.85)
                  : AppColors.surface.withOpacity(0.65),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isHovered
                    ? teamColor.withOpacity(0.45)
                    : AppColors.glassBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? teamColor.withOpacity(0.18)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        PlayerAvatar(
                          name: player.name,
                          profileImageUrl: player.profileImageUrl,
                          size: 52,
                          accentColor: teamColor,
                          borderRadius: 16,
                        ),
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: teamColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: teamColor.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  player.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPositionBadge(context, player.position),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            player.teamName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: teamColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            player.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${player.seasonMatches}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Matches',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 9,
                              ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
