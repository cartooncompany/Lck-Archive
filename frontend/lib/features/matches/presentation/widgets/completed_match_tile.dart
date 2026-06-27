import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/extensions/date_extensions.dart';
import 'package:frontend/shared/models/lck_match_detail.dart';
import 'package:frontend/shared/models/lck_scheduled_match.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/shared/widgets/team_logo.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';

class CompletedMatchTile extends StatelessWidget {
  const CompletedMatchTile({
    required this.match,
    this.onOpenDetail,
    super.key,
  });

  final LckMatchDetail match;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final note = [
      match.split.trim(),
      match.stage.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');

    final isHomeWinner = match.winner?.id == match.homeTeam.id;
    final isAwayWinner = match.winner?.id == match.awayTeam.id;

    TeamSummary? favoriteTeam;
    try {
      favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    } catch (_) {}
    final isMyTeamMatch = favoriteTeam != null && 
        (match.homeTeam.id == favoriteTeam.id || match.awayTeam.id == favoriteTeam.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isMyTeamMatch
                    ? favoriteTeam.color.withValues(alpha: 0.15)
                    : AppColors.surface.withValues(alpha: 0.65),
                isMyTeamMatch
                    ? favoriteTeam.color.withValues(alpha: 0.05)
                    : AppColors.surfaceMuted.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isMyTeamMatch
                  ? favoriteTeam.color.withValues(alpha: 0.5)
                  : AppColors.glassBorderMuted,
              width: isMyTeamMatch ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isMyTeamMatch
                    ? favoriteTeam.color.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: isMyTeamMatch ? 20 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.scheduledAt.toKoreanMonthDayTime(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  if (isMyTeamMatch) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: favoriteTeam.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: favoriteTeam.color.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'MY TEAM',
                        style: TextStyle(
                          color: favoriteTeam.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: AppColors.neonGlow(
                        color: AppColors.success,
                        blurRadius: 4,
                      ),
                    ),
                    child: const Text(
                      '종료',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _TeamSlot(
                      team: match.homeTeam,
                      alignEnd: false,
                      isWinner: isHomeWinner,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '${match.score.home} : ${match.score.away}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TeamSlot(
                      team: match.awayTeam,
                      alignEnd: true,
                      isWinner: isAwayWinner,
                    ),
                  ),
                ],
              ),
              if (onOpenDetail != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onOpenDetail,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '상세 보기',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 11),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamSlot extends StatelessWidget {
  const _TeamSlot({
    required this.team,
    required this.alignEnd,
    required this.isWinner,
  });

  final LckScheduledTeam team;
  final bool alignEnd;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    final crossAxisAlignment =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final logo = TeamLogo(
      initials: team.shortName,
      logoUrl: team.logoUrl,
      size: 44,
      backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
      borderColor: isWinner
          ? AppColors.success.withValues(alpha: 0.5)
          : AppColors.divider,
      foregroundColor: AppColors.textPrimary,
      borderRadius: 14,
    );
    final details = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          team.shortName,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.w700,
                color: isWinner ? AppColors.textPrimary : AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          team.name,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isWinner ? AppColors.textSecondary : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [Flexible(child: details), const SizedBox(width: 10), logo]
          : [logo, const SizedBox(width: 10), Flexible(child: details)],
    );
  }
}
