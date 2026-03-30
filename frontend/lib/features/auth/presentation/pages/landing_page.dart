import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/session_controller.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final horizontalPadding = isWide ? 40.0 : 24.0;

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF040816),
                  AppColors.background,
                  Color(0xFF0A1A38),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const _BackdropGlow(),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: isWide
                                    ? constraints.maxHeight - 64
                                    : 0,
                              ),
                              child: isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 11,
                                          child: _HeroCopy(
                                            onStart: session.showLogin,
                                            onGuest: session.continueAsGuest,
                                          ),
                                        ),
                                        const SizedBox(width: 36),
                                        const Expanded(
                                          flex: 9,
                                          child: _ArenaPoster(),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _HeroCopy(
                                          onStart: session.showLogin,
                                          onGuest: session.continueAsGuest,
                                        ),
                                        const SizedBox(height: 28),
                                        const _ArenaPoster(),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 24),
                            const _SignalStrip(),
                            const SizedBox(height: 28),
                            isWide
                                ? const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _FeatureBlock(
                                          index: '01',
                                          title: '응원팀 기준으로 홈을 재정렬',
                                          body:
                                              '팀 카드, 최근 경기, 주요 선수, 뉴스를 한 흐름으로 엮어 첫 화면에서 바로 이어 봅니다.',
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Expanded(
                                        child: _FeatureBlock(
                                          index: '02',
                                          title: '경기와 선수 기록을 빠르게 넘겨보기',
                                          body:
                                              '탭 이동은 단순하게 유지하고, 중요한 정보는 큰 타이포와 대비로 먼저 보이게 구성했습니다.',
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Expanded(
                                        child: _FeatureBlock(
                                          index: '03',
                                          title: '로그인 후 바로 개인 아카이브 시작',
                                          body:
                                              '실제 인증 연동 전에도 진입 흐름을 검증할 수 있도록 랜딩, 로그인, 로그아웃 전환을 연결했습니다.',
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _FeatureBlock(
                                        index: '01',
                                        title: '응원팀 기준으로 홈을 재정렬',
                                        body:
                                            '팀 카드, 최근 경기, 주요 선수, 뉴스를 한 흐름으로 엮어 첫 화면에서 바로 이어 봅니다.',
                                      ),
                                      SizedBox(height: 18),
                                      _FeatureBlock(
                                        index: '02',
                                        title: '경기와 선수 기록을 빠르게 넘겨보기',
                                        body:
                                            '탭 이동은 단순하게 유지하고, 중요한 정보는 큰 타이포와 대비로 먼저 보이게 구성했습니다.',
                                      ),
                                      SizedBox(height: 18),
                                      _FeatureBlock(
                                        index: '03',
                                        title: '로그인 후 바로 개인 아카이브 시작',
                                        body:
                                            '실제 인증 연동 전에도 진입 흐름을 검증할 수 있도록 랜딩, 로그인, 로그아웃 전환을 연결했습니다.',
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 28),
                            _ClosingBanner(onPressed: session.showLogin),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onStart, required this.onGuest});

  final VoidCallback onStart;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            '2026 SPRING SPLIT ARCHIVE',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.appName,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '승부의 온도와 선수의 흐름을\n한 장면씩 다시 여는 개인 전광판',
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 46,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.6,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            '응원팀 기준으로 경기, 선수, 뉴스가 한 호흡으로 이어지는 LCK 전용 아카이브입니다. 첫 화면은 포스터처럼 크게, 진입은 로그인 한 번으로 빠르게 정리했습니다.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              child: const Text('로그인하고 시작하기'),
            ),
            OutlinedButton(
              onPressed: onGuest,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              child: const Text('게스트로 둘러보기'),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _TagChip(label: '응원팀 기반 홈'),
            _TagChip(label: '선수 기록 탐색'),
            _TagChip(label: '주간 뉴스 큐레이션'),
          ],
        ),
      ],
    );
  }
}

class _ArenaPoster extends StatelessWidget {
  const _ArenaPoster();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        gradient: const LinearGradient(
          colors: [Color(0xFF111C35), Color(0xFF07101F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'RIVALRY PULSE',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.wifi_tethering_rounded,
                color: AppColors.accent.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '오늘의 아카이브',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '최근 경기 흐름과 주요 선수를 큰 대비로 정리해서, 첫 진입부터 어디를 눌러야 할지 바로 보이게 설계했습니다.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            height: 188,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF16294F), Color(0xFF0C1730)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 28,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentStrong.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'T1  vs  GEN',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '2',
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: 58,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '1',
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: 40,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'RIVALRY\nHIGHLIGHT',
                            textAlign: TextAlign.right,
                            style: textTheme.labelLarge?.copyWith(
                              height: 1.35,
                              color: AppColors.textPrimary,
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
          const SizedBox(height: 18),
          const _PosterRow(
            title: 'Key player',
            body: 'Faker, Chovy, Viper 흐름을 같은 문맥에서 연결',
          ),
          const SizedBox(height: 12),
          const _PosterRow(
            title: 'Weekly brief',
            body: '경기 결과와 관련 뉴스가 한 번에 이어지는 홈 동선',
          ),
          const SizedBox(height: 12),
          const _PosterRow(
            title: 'Fast search',
            body: '선수와 팀을 빠르게 오가도록 탐색 탭 간격 최소화',
          ),
        ],
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            title.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.86),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignalStrip extends StatelessWidget {
  const _SignalStrip();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _SignalItem(
            label: 'HOME SIGNAL',
            value: '응원팀 중심',
            textTheme: textTheme,
          ),
          _SignalItem(
            label: 'PLAYER TRACK',
            value: '핵심 선수 추적',
            textTheme: textTheme,
          ),
          _SignalItem(
            label: 'NEWS BRIEF',
            value: '주간 이슈 연결',
            textTheme: textTheme,
          ),
          _SignalItem(
            label: 'ENTRY FLOW',
            value: '랜딩 -> 로그인 -> 메인',
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _SignalItem extends StatelessWidget {
  const _SignalItem({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _FeatureBlock extends StatelessWidget {
  const _FeatureBlock({
    required this.index,
    required this.title,
    required this.body,
  });

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.accent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingBanner extends StatelessWidget {
  const _ClosingBanner({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ClosingCopy(textTheme: textTheme)),
                const SizedBox(width: 24),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('로그인 화면으로 이동'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClosingCopy(textTheme: textTheme),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    child: const Text('로그인 화면으로 이동'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ClosingCopy extends StatelessWidget {
  const _ClosingCopy({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '응원팀을 고르면 첫 화면부터 바로 달라집니다.',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          '로그인 뒤 설정에서 응원팀을 바꾸면 홈, 선수, 뉴스 탭의 기준도 함께 바뀌도록 현재 구조와 연결했습니다.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -110,
            top: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 120,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentStrong.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: -140,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
