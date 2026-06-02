import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../../../matches/presentation/widgets/form_strip.dart';

/// LCK Archive의 팀 목록 및 홈 화면 순위표에서 각 팀의 정보를 렌더링하는 고급 순위 카드 위젯입니다.
/// 상위 순위(1~3위)에 대한 눈부신 네온 메달리온 장식과 1위 팀의 왕관 광원 필터 효과,
/// 팀 고유 네온 테두리 링 및 디바이스 너비에 따른 세밀한 가로/세로 그리드 정렬을 탑재하여
/// e스포츠 고유의 역동적이고 프리미엄한 비주얼을 제공합니다.
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
    final rank = team.rank;

    // 순위별 프리미엄 광원 색상 및 특별 심볼 매핑
    Color rankColor;
    String rankBadge = '';
    List<BoxShadow>? rankGlow;

    if (rank == 1) {
      rankColor = AppColors.warning; // 골드
      rankBadge = '👑';
      rankGlow = AppColors.neonGlow(color: AppColors.warning, blurRadius: 8);
    } else if (rank == 2) {
      rankColor = const Color(0xFFD8DEE9); // 실버
      rankGlow = AppColors.neonGlow(color: const Color(0xFFE5E9F0), blurRadius: 6);
    } else if (rank == 3) {
      rankColor = const Color(0xFFFF8A65); // 브론즈 (코퍼 로즈)
      rankGlow = AppColors.neonGlow(color: const Color(0xFFFF8A65), blurRadius: 5);
    } else {
      rankColor = AppColors.textSecondary;
      rankGlow = null;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : (_isHovered ? 1.025 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _isHovered ? -5.0 : 0.0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              // 1위 카드에는 은은한 왕관 골드 그라데이션 기운을 결합하여 영예 극대화
              gradient: rank == 1
                  ? LinearGradient(
                      colors: [
                        AppColors.surface.withValues(alpha: 0.7),
                        AppColors.surfaceElevated.withValues(alpha: 0.8),
                        AppColors.warning.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        _isHovered
                            ? AppColors.surfaceElevated.withValues(alpha: 0.85)
                            : AppColors.surface.withValues(alpha: 0.55),
                        _isHovered
                            ? AppColors.surfaceElevated.withValues(alpha: 0.65)
                            : AppColors.surface.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: _isHovered
                    ? teamColor.withValues(alpha: 0.7)
                    : (rank == 1
                        ? AppColors.warning.withValues(alpha: 0.3) // 1위 골드 라인
                        : AppColors.glassBorderMuted),
                width: rank == 1 ? 1.4 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? teamColor.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.16),
                  blurRadius: _isHovered ? 24 : 10,
                  spreadRadius: _isHovered ? 1 : 0,
                  offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
                ),
                if (rank == 1 && !_isHovered)
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.05),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  // 은은한 구석탱이 네온 글로우 백그라운드 레이어
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Container(
                      key: ValueKey('glow_${team.id}'),
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (rank == 1 ? AppColors.warning : teamColor)
                                .withValues(alpha: _isHovered ? 0.16 : 0.06),
                            (rank == 1 ? AppColors.warning : teamColor)
                                .withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 430;

                      Widget buildMainRow() {
                        return Row(
                          children: [
                            // 1. 웅장한 순위 메달리온 영역
                            Container(
                              width: 44,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (rankBadge.isNotEmpty) ...[
                                    Text(
                                      rankBadge,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    rank > 0 ? '$rank' : '-',
                                    style: TextStyle(
                                      fontSize: rank <= 3 ? 28 : 22,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      color: rankColor,
                                      shadows: [
                                        if (rankGlow != null)
                                          ...rankGlow.map((b) => Shadow(
                                                color: b.color.withValues(alpha: 0.4),
                                                blurRadius: b.blurRadius,
                                              )),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'RANK',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      color: rankColor.withValues(alpha: 0.5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. 팀 로고 (팀 네온 링 장착)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: teamColor.withValues(alpha: _isHovered ? 0.75 : 0.2),
                                  width: _isHovered ? 1.5 : 1.0,
                                ),
                                boxShadow: [
                                  if (_isHovered)
                                    BoxShadow(
                                      color: teamColor.withValues(alpha: 0.12),
                                      blurRadius: 8,
                                    ),
                                ],
                              ),
                              child: TeamLogo(
                                initials: team.initials,
                                logoUrl: team.logoUrl,
                                size: 52,
                                foregroundColor: teamColor,
                                borderRadius: 18,
                                textStyle: TextStyle(
                                  color: teamColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // 3. 팀 전적 정보
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: -0.4,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${team.seasonRecord}  |  세트 ${team.setRecord}',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // 4. 최근 폼 (가로 레이아웃 우측)
                            if (!isCompact) ...[
                              const SizedBox(width: 12),
                              FormStrip(form: team.recentForm),
                            ],
                          ],
                        );
                      }

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildMainRow(),
                            const SizedBox(height: 12),
                            // 순위(44) + 간격(8) + 로고 패딩포함(56) + 간격(14) = 122px 오프셋 정렬
                            Padding(
                              padding: const EdgeInsets.only(left: 122),
                              child: FormStrip(form: team.recentForm),
                            ),
                          ],
                        );
                      }

                      return buildMainRow();
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
