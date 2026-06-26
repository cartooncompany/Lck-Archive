import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../../../favorite_team/presentation/bloc/favorite_team_controller.dart';

class ScheduledMatchTile extends StatefulWidget {
  const ScheduledMatchTile({
    required this.match,
    this.predictedWinnerTeamId,
    this.onPredictWinner,
    this.onOpenDetail,
    super.key,
  });

  final LckScheduledMatch match;
  final String? predictedWinnerTeamId;
  final ValueChanged<String>? onPredictWinner;
  final VoidCallback? onOpenDetail;

  @override
  State<ScheduledMatchTile> createState() => _ScheduledMatchTileState();
}

class _ScheduledMatchTileState extends State<ScheduledMatchTile> {
  late LckScheduledMatch _currentMatch;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
  }

  @override
  void didUpdateWidget(covariant ScheduledMatchTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) {
      _currentMatch = widget.match;
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = _currentMatch.note;

    TeamSummary? favoriteTeam;
    try {
      favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    } catch (_) {}
    final isMyTeamMatch = favoriteTeam != null && 
        (_currentMatch.homeTeam.id == favoriteTeam.id || _currentMatch.awayTeam.id == favoriteTeam.id);

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
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentMatch.scheduledAt.toKoreanMonthDayTime(),
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
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: AppColors.neonGlow(
                        color: AppColors.warning,
                        blurRadius: 4,
                      ),
                    ),
                    child: const Text(
                      '예정',
                      style: TextStyle(
                        color: AppColors.warning,
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
                    child: _TeamSlot(team: _currentMatch.homeTeam, alignEnd: false),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceElevated,
                          AppColors.surfaceMuted,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: AppColors.neonGlow(
                        color: AppColors.accent,
                        blurRadius: 6,
                      ),
                    ),
                    child: Text(
                      'VS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        fontSize: 13,
                        shadows: [
                          Shadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TeamSlot(team: _currentMatch.awayTeam, alignEnd: true),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '승부 예측',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.predictedWinnerTeamId == null
                          ? AppColors.surfaceMuted.withValues(alpha: 0.6)
                          : AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.predictedWinnerTeamId == null
                            ? AppColors.divider
                            : AppColors.accent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      widget.predictedWinnerTeamId == null ? '예측 미수행' : '예측 완료',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.predictedWinnerTeamId == null
                            ? AppColors.textMuted
                            : AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PredictionButton(
                      team: _currentMatch.homeTeam,
                      isSelected: widget.predictedWinnerTeamId == _currentMatch.homeTeam.id,
                      onTap: widget.onPredictWinner == null
                          ? null
                          : () => widget.onPredictWinner!(_currentMatch.homeTeam.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PredictionButton(
                      team: _currentMatch.awayTeam,
                      isSelected: widget.predictedWinnerTeamId == _currentMatch.awayTeam.id,
                      onTap: widget.onPredictWinner == null
                          ? null
                          : () => widget.onPredictWinner!(_currentMatch.awayTeam.id),
                    ),
                  ),
                ],
              ),
              if (widget.onOpenDetail != null) ...[
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
                    onPressed: widget.onOpenDetail,
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
  const _TeamSlot({required this.team, required this.alignEnd});

  final LckScheduledTeam team;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    final crossAxisAlignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final logo = TeamLogo(
      initials: team.shortName,
      logoUrl: team.logoUrl,
      size: 48,
      backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
      borderColor: AppColors.divider,
      foregroundColor: AppColors.textPrimary,
      borderRadius: 16,
    );
    final details = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          team.shortName,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          team.name,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: alignEnd
          ? [Flexible(child: details), const SizedBox(width: 12), logo]
          : [logo, const SizedBox(width: 12), Flexible(child: details)],
    );
  }
}

class _PredictionButton extends StatefulWidget {
  const _PredictionButton({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  final LckScheduledTeam team;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<_PredictionButton> createState() => _PredictionButtonState();
}

class _PredictionButtonState extends State<_PredictionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.accent;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.16),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: isSelected
              ? activeColor.withValues(alpha: 0.14)
              : AppColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: activeColor.withValues(alpha: 0.05),
            splashColor: activeColor.withValues(alpha: 0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : (_isHovered
                            ? AppColors.textSecondary.withValues(alpha: 0.4)
                            : AppColors.glassBorderMuted),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.team.shortName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? '나의 승리 예측' : '승리 예측하기',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
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
