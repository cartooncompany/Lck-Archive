import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/widgets/team_logo.dart';

class ScheduledMatchTile extends StatelessWidget {
  const ScheduledMatchTile({
    required this.match,
    this.predictedWinnerTeamId,
    this.onPredictWinner,
    super.key,
  });

  final LckScheduledMatch match;
  final String? predictedWinnerTeamId;
  final ValueChanged<String>? onPredictWinner;

  @override
  Widget build(BuildContext context) {
    final note = match.note;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.scheduledAt.toKoreanMonthDayTime(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '예정',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              note,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _TeamSlot(team: match.homeTeam, alignEnd: false)),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  'VS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(child: _TeamSlot(team: match.awayTeam, alignEnd: true)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '승부 예측',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                predictedWinnerTeamId == null ? '미선택' : '선택 완료',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: predictedWinnerTeamId == null
                      ? AppColors.textSecondary
                      : AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PredictionButton(
                  team: match.homeTeam,
                  isSelected: predictedWinnerTeamId == match.homeTeam.id,
                  onTap: onPredictWinner == null
                      ? null
                      : () => onPredictWinner!(match.homeTeam.id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PredictionButton(
                  team: match.awayTeam,
                  isSelected: predictedWinnerTeamId == match.awayTeam.id,
                  onTap: onPredictWinner == null
                      ? null
                      : () => onPredictWinner!(match.awayTeam.id),
                ),
              ),
            ],
          ),
        ],
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
      backgroundColor: AppColors.surfaceElevated,
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          team.name,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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

class _PredictionButton extends StatelessWidget {
  const _PredictionButton({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  final LckScheduledTeam team;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.accentStrong.withValues(alpha: 0.18)
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accentStrong : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.shortName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSelected ? '승리 예측 중' : '승리 선택',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
