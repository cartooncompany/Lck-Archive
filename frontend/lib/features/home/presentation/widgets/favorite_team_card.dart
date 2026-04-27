import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/media_url_resolver.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../matches/presentation/widgets/form_strip.dart';

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;
          final titleFontSize = isCompact ? 36.0 : 48.0;

          return Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [heroStartColor, heroEndColor],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Opacity(
                                  opacity: 0.22,
                                  child: resolvedLogoUrl != null
                                      ? Image.network(
                                          resolvedLogoUrl,
                                          width: 320,
                                          height: 320,
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
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.08),
                                      Colors.black.withValues(alpha: 0.02),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.42, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '응원팀',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  const Spacer(),
                                  _RankBadge(rankLabel: team.rankLabel),
                                ],
                              ),
                              const SizedBox(height: 28),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            fontSize: titleFontSize,
                                            height: 0.92,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1.8,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      team.summary,
                                      maxLines: isCompact ? 3 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.88,
                                            ),
                                            height: 1.55,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '최근 5경기',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            streakLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FormStrip(form: team.recentForm),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.76),
                fontWeight: FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '현재 순위',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            rankLabel,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
