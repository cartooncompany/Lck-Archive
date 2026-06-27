import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/models/player_profile.dart';
import 'package:frontend/shared/widgets/player_avatar.dart';

class KeyPlayerCard extends StatefulWidget {
  const KeyPlayerCard({required this.player, required this.onTap, super.key});

  final PlayerProfile player;
  final VoidCallback onTap;

  @override
  State<KeyPlayerCard> createState() => _KeyPlayerCardState();
}

class _KeyPlayerCardState extends State<KeyPlayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = widget.player.teamColor;
    final borderRadius = BorderRadius.circular(22);

    return SizedBox(
      width: 196,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -6.0 : 0.0, 0.0),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surface.withValues(alpha: 0.65),
                          AppColors.surfaceMuted.withValues(alpha: 0.45),
                        ],
                      ),
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: _isHovered
                            ? teamColor.withValues(alpha: 0.55)
                            : teamColor.withValues(alpha: 0.2),
                        width: _isHovered ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: teamColor.withValues(
                            alpha: _isHovered ? 0.12 : 0.04,
                          ),
                          blurRadius: _isHovered ? 16 : 8,
                          offset: Offset(0, _isHovered ? 8 : 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PlayerAvatar(
                              name: widget.player.name,
                              profileImageUrl: widget.player.profileImageUrl,
                              size: 42,
                              accentColor: teamColor,
                              borderRadius: 14,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: teamColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: teamColor.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                widget.player.position,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: teamColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.player.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            widget.player.headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '시즌 경기',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              '${widget.player.seasonMatches} Match',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: teamColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
