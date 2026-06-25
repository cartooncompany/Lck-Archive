import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../../shared/widgets/team_logo.dart';

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
  bool _isLoadingPrediction = false;
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

  Future<void> _generateAiPrediction() async {
    setState(() {
      _isLoadingPrediction = true;
    });

    try {
      final repository = AppDependenciesScope.of(context).matchesRepository;
      await repository.requestMatchAiPrediction(_currentMatch.id);
      
      final updatedMatch = await repository.getMatchDetail(_currentMatch.id);
      if (mounted) {
        setState(() {
          _currentMatch = LckScheduledMatch(
            id: updatedMatch.id,
            scheduledAt: updatedMatch.scheduledAt,
            split: updatedMatch.split,
            stage: updatedMatch.stage,
            status: updatedMatch.status,
            homeTeam: updatedMatch.homeTeam,
            awayTeam: updatedMatch.awayTeam,
            aiWinnerTeamId: updatedMatch.aiWinnerTeamId,
            aiPrediction: updatedMatch.aiPrediction,
          );
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 예측 분석 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrediction = false;
        });
      }
    }
  }

  Widget _buildAiPredictionSection(BuildContext context) {
    if (_isLoadingPrediction) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: const Column(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
            SizedBox(height: 8),
            Text(
              'Archive Assistant가 최근 경기 통계 데이터를 기반으로 분석하고 있어요...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final aiPrediction = _currentMatch.aiPrediction;
    if (aiPrediction == null || aiPrediction.trim().isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.glassBorderMuted),
            ),
          ),
          onPressed: _generateAiPrediction,
          icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accent),
          label: const Text(
            'AI 승부 예측 리포트 확인하기',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    Map<String, dynamic>? aiPredictionMap;
    try {
      aiPredictionMap = jsonDecode(aiPrediction) as Map<String, dynamic>;
    } catch (_) {}

    if (aiPredictionMap == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'AI 예측: ${aiPredictionMap['winnerTeamName']} 우세 (${aiPredictionMap['probability']}% 확률)',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            aiPredictionMap['reason'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = _currentMatch.note;

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
                AppColors.surface.withValues(alpha: 0.65),
                AppColors.surfaceMuted.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.glassBorderMuted, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
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
              const SizedBox(height: 12),
              _buildAiPredictionSection(context),
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
