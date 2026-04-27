import 'package:flutter/material.dart';

import 'auth_shell.dart';

class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({
    required this.onStart,
    required this.onGuest,
    required this.onSignUp,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onGuest;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthGlassPanel(
          padding: const EdgeInsets.all(32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              final isCompact = constraints.maxWidth < 680;
              final headline = isNarrow
                  ? '좋아하는 팀 기준으로\nLCK를 더 빠르게\n봅니다.'
                  : isCompact
                  ? '좋아하는 팀 기준으로\nLCK를 더 빠르게 봅니다.'
                  : '좋아하는 팀을 중심으로\nLCK를 더 빠르게 봅니다.';
              final headlineFontSize = isNarrow
                  ? 34.0
                  : isCompact
                  ? 38.0
                  : 42.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthSectionBadge(label: 'LCK Archive 계정'),
                  const SizedBox(height: 18),
                  Text(
                    headline,
                    style: textTheme.headlineLarge?.copyWith(
                      color: AuthUiColors.heroText,
                      fontSize: headlineFontSize,
                      height: isNarrow ? 1.14 : 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: isNarrow ? -1.0 : -1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      '로그인하면 응원팀 기준 홈, 프로필, 저장된 세션이 그대로 이어집니다. 계정이 없어도 게스트로 먼저 둘러보고 나중에 연결할 수 있습니다.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AuthUiColors.heroMuted,
                        fontSize: isNarrow ? 14 : 15,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      AuthFeaturePill(label: '응원팀 개인화'),
                      AuthFeaturePill(label: '경기 일정'),
                      AuthFeaturePill(label: '뉴스 아카이브'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AuthUiColors.ink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('로그인하고 시작'),
                      ),
                      OutlinedButton(
                        onPressed: onSignUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuthUiColors.heroText,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('회원가입'),
                      ),
                      TextButton(
                        onPressed: onGuest,
                        style: TextButton.styleFrom(
                          foregroundColor: AuthUiColors.heroMuted,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 14,
                          ),
                        ),
                        child: const Text('게스트로 둘러보기'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = _gridItemWidth(constraints.maxWidth);

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: const AuthMetricCard(
                    icon: Icons.home_rounded,
                    label: '홈',
                    value: '응원팀 기준으로 첫 화면 정리',
                    description: '팀 카드, 일정, 순위, 주요 뉴스를 한 흐름으로 바로 이어서 봅니다.',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const AuthMetricCard(
                    icon: Icons.grid_view_rounded,
                    label: '탐색',
                    value: '팀과 선수를 바로 찾기',
                    description:
                        '팀 순위, 선수 기록, 일정 화면을 같은 구조 안에서 자연스럽게 오갈 수 있습니다.',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const AuthMetricCard(
                    icon: Icons.person_outline_rounded,
                    label: '세션',
                    value: '로그인 상태와 프로필 유지',
                    description: '다음에 다시 들어와도 내 계정과 응원팀 기준이 그대로 이어집니다.',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  double _gridItemWidth(double maxWidth) {
    if (maxWidth >= 900) {
      return (maxWidth - 24) / 3;
    }
    if (maxWidth >= 600) {
      return (maxWidth - 12) / 2;
    }
    return maxWidth;
  }
}

class LandingDashboardPreviewSection extends StatelessWidget {
  const LandingDashboardPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AuthGlassPanel(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '로그인 후 바로 이어지는 정보',
            style: textTheme.titleLarge?.copyWith(
              color: AuthUiColors.heroText,
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '응원팀, 경기 일정, 주요 뉴스, 프로필을 다시 찾지 않도록 첫 화면 기준을 한 번에 정리했습니다.',
            style: textTheme.bodyMedium?.copyWith(
              color: AuthUiColors.heroMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const _LandingPreviewBoard(),
        ],
      ),
    );
  }
}

class _LandingPreviewBoard extends StatelessWidget {
  const _LandingPreviewBoard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return const Column(
            children: [
              _FavoriteTeamPreviewCard(),
              SizedBox(height: 12),
              _SchedulePreviewCard(),
              SizedBox(height: 12),
              _ProfileNewsPreviewCard(),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 11, child: _FavoriteTeamPreviewCard()),
            SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: Column(
                children: [
                  _SchedulePreviewCard(),
                  SizedBox(height: 12),
                  _ProfileNewsPreviewCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteTeamPreviewCard extends StatelessWidget {
  const _FavoriteTeamPreviewCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '응원팀 홈',
            style: textTheme.labelLarge?.copyWith(
              color: AuthUiColors.heroMuted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'T1',
            style: textTheme.headlineSmall?.copyWith(
              color: AuthUiColors.heroText,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1위  |  14-3  |  세트 +18',
            style: textTheme.bodyMedium?.copyWith(
              color: AuthUiColors.heroMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '최근 5경기',
            style: textTheme.labelLarge?.copyWith(
              color: AuthUiColors.heroMuted,
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            children: [
              _FormDot(label: 'W', isWin: true),
              _FormDot(label: 'W', isWin: true),
              _FormDot(label: 'W', isWin: true),
              _FormDot(label: 'L', isWin: false),
              _FormDot(label: 'W', isWin: true),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: AuthUiColors.heroText,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '관련 뉴스와 최근 경기 결과가 홈에서 바로 이어집니다.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AuthUiColors.heroMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SchedulePreviewCard extends StatelessWidget {
  const _SchedulePreviewCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘 경기',
            style: textTheme.labelLarge?.copyWith(
              color: AuthUiColors.heroMuted,
            ),
          ),
          const SizedBox(height: 12),
          const _ScheduleItem(time: '17:00', home: 'T1', away: 'Gen.G'),
          const SizedBox(height: 10),
          const _ScheduleItem(time: '19:30', home: 'HLE', away: 'DK'),
        ],
      ),
    );
  }
}

class _ProfileNewsPreviewCard extends StatelessWidget {
  const _ProfileNewsPreviewCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계정과 프로필',
            style: textTheme.labelLarge?.copyWith(
              color: AuthUiColors.heroMuted,
            ),
          ),
          const SizedBox(height: 12),
          const _PreviewListTile(
            icon: Icons.person_outline_rounded,
            title: '프로필과 로그인 상태 유지',
            subtitle: '다음 방문에도 같은 계정으로 바로 이어집니다.',
          ),
          const SizedBox(height: 10),
          const _PreviewListTile(
            icon: Icons.push_pin_outlined,
            title: '응원팀 기준 개인화',
            subtitle: '설정에서 팀을 바꾸면 홈 기준도 함께 바뀝니다.',
          ),
        ],
      ),
    );
  }
}

class _FormDot extends StatelessWidget {
  const _FormDot({required this.label, required this.isWin});

  final String label;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isWin
            ? const Color(0xFF1ED48A).withValues(alpha: 0.18)
            : const Color(0xFFFF6B6B).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isWin
              ? const Color(0xFF1ED48A).withValues(alpha: 0.48)
              : const Color(0xFFFF6B6B).withValues(alpha: 0.48),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({
    required this.time,
    required this.home,
    required this.away,
  });

  final String time;
  final String home;
  final String away;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            time,
            style: textTheme.bodySmall?.copyWith(color: AuthUiColors.heroMuted),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$home  vs  $away',
              style: textTheme.bodyMedium?.copyWith(
                color: AuthUiColors.heroText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewListTile extends StatelessWidget {
  const _PreviewListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AuthUiColors.heroText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: AuthUiColors.heroText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AuthUiColors.heroMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
