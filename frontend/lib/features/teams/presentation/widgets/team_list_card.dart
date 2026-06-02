import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../../../matches/presentation/widgets/form_strip.dart';

class TeamListCard extends StatefulWidget {
  const TeamListCard({required this.team, required this.onTap, super.key});

  final TeamSummary team;
  final VoidCallback onTap;

  @override
  State<TeamListCard> createState() => _TeamListCardState();
}

class _TeamListCardState extends State<TeamListCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final teamColor = team.color;

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceElevated.withOpacity(0.8)
                  : AppColors.surface.withOpacity(0.55),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? teamColor.withOpacity(0.5)
                    : AppColors.glassBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? teamColor.withOpacity(0.18)
                      : Colors.black.withOpacity(0.12),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // 은은한 팀 컬러 백그라운드 글로우 레이어
                  Positioned(
                    right: -40,
                    bottom: -40,
                    child: Container(
                      key: ValueKey('glow_${team.id}'),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: teamColor.withOpacity(_isHovered ? 0.08 : 0.03),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Stack(
                            children: [
                              TeamLogo(
                                initials: team.initials,
                                logoUrl: team.logoUrl,
                                size: 64,
                                foregroundColor: teamColor,
                                borderRadius: 20,
                                textStyle: TextStyle(
                                  color: teamColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              if (_isHovered)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: teamColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        team.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: teamColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: teamColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        team.rankLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: teamColor,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${team.seasonRecord}  |  세트 ${team.setRecord}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                FormStrip(form: team.recentForm),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
