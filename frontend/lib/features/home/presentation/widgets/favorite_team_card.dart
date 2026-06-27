import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/core/network/media_url_resolver.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/features/matches/presentation/widgets/form_strip.dart';

class FavoriteTeamCard extends StatelessWidget {
  const FavoriteTeamCard({required this.team, required this.onTap, super.key});

  final TeamSummary team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedLogoUrl = resolveMediaUrl(team.logoUrl);
    final formSummary = _buildFormSummary(team.recentForm);
    final streakLabel = _buildStreakLabel(team.recentForm);
    final heroStartColor = _buildHeroStartColor();
    final heroEndColor = _buildHeroEndColor();
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            final titleFontSize = isCompact ? 34.0 : 44.0;

            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: team.color.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: team.color.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 핵심 전적 정보 패널 (그라디언트 카드)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // 그라디언트 배경
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      heroStartColor.withValues(alpha: 0.85),
                                      heroEndColor.withValues(alpha: 0.65),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),

                            // 팀 로고 백그라운드 워터마크
                            Positioned.fill(
                              child: IgnorePointer(
                                child: ExcludeSemantics(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Opacity(
                                      opacity: 0.16,
                                      child: resolvedLogoUrl != null
                                          ? Image.network(
                                              resolvedLogoUrl,
                                              width: 300,
                                              height: 300,
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder: (_, _, _) =>
                                                  _BackgroundMonogram(
                                                    initials: team.initials,
                                                  ),
                                            )
                                          : _BackgroundMonogram(
                                              initials: team.initials,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 글래스 그라디언트 딤 효과
                            Positioned.fill(
                              child: IgnorePointer(
                                child: ExcludeSemantics(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.15),
                                          Colors.black.withValues(alpha: 0.05),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.45, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 컨텐츠
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'MY TEAM',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      _RankBadge(rankLabel: team.rankLabel),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 420,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          team.name,
                                          style: textTheme.headlineLarge
                                              ?.copyWith(
                                                fontSize: titleFontSize,
                                                height: 0.95,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: -1.2,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          team.summary,
                                          maxLines: isCompact ? 3 : 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            height: 1.5,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  if (isCompact) ...[
                                    _HeroStatChip(
                                      label: '전적',
                                      value: team.seasonRecord,
                                    ),
                                    const SizedBox(height: 10),
                                    _HeroStatChip(
                                      label: '세트 득실',
                                      value: team.setRecord,
                                    ),
                                    const SizedBox(height: 10),
                                    _HeroStatChip(
                                      label: '최근 흐름',
                                      value: formSummary,
                                      caption: streakLabel,
                                    ),
                                  ] else
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _HeroStatChip(
                                            label: '전적',
                                            value: team.seasonRecord,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _HeroStatChip(
                                            label: '세트 득실',
                                            value: team.setRecord,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _HeroStatChip(
                                            label: '최근 흐름',
                                            value: formSummary,
                                            caption: streakLabel,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. 최근 5경기 패널
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withValues(
                                alpha: 0.45,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.history_rounded,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '최근 5경기',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (streakLabel.contains('승')
                                                    ? AppColors.success
                                                    : AppColors.danger)
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        streakLabel,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: streakLabel.contains('승')
                                              ? AppColors.success
                                              : AppColors.danger,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                FormStrip(form: team.recentForm),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildFormSummary(List<String> form) {
    if (form.isEmpty) {
      return '-';
    }

    final wins = form.where((entry) => entry == 'W').length;
    final losses = form.where((entry) => entry == 'L').length;
    return '$wins승 $losses패';
  }

  String _buildStreakLabel(List<String> form) {
    if (form.isEmpty) {
      return '기록 없음';
    }

    final pivot = form.first;
    var streakCount = 0;
    for (final entry in form) {
      if (entry != pivot) {
        break;
      }
      streakCount += 1;
    }

    return pivot == 'W' ? '$streakCount연승' : '$streakCount연패';
  }

  Color _buildHeroStartColor() {
    if (_isT1Team) {
      return const Color(0xFFC4382E);
    }

    return Color.lerp(team.color, Colors.white, 0.06)!.withValues(alpha: 0.98);
  }

  Color _buildHeroEndColor() {
    if (_isT1Team) {
      return const Color(0xFF681E19);
    }

    return Color.lerp(team.color, AppColors.background, 0.5)!;
  }

  bool get _isT1Team {
    final normalizedName = team.name.trim().toUpperCase();
    final normalizedInitials = team.initials.trim().toUpperCase();
    return normalizedName == 'T1' || normalizedInitials == 'T1';
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rankLabel});

  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '현재 순위',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rankLabel,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundMonogram extends StatelessWidget {
  const _BackgroundMonogram({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontSize: 180,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -6,
      ),
    );
  }
}
