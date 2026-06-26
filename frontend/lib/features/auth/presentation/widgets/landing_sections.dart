import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'auth_shell.dart';

/// 스태거(순차) 진입용 페이드 인 & 슬라이드 업 애니메이션 위젯
class _FadeInSlideUp extends StatefulWidget {
  const _FadeInSlideUp({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  State<_FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<_FadeInSlideUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 탭 시 쫀득한 스케일 축소/복원 효과를 주는 바운스 액션 위젯
class _BounceAction extends StatefulWidget {
  const _BounceAction({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BounceAction> createState() => _BounceActionState();
}

class _BounceActionState extends State<_BounceAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

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

    return AuthGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 100),
            child: AuthSectionBadge(label: 'LCK Archive'),
          ),
          const SizedBox(height: 20),
          _FadeInSlideUp(
            delay: const Duration(milliseconds: 200),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'LCK 경기 기록을\n빠르게 확인하세요.',
                style: textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FadeInSlideUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              '팀, 선수, 경기 일정과 최신 뉴스를 한 곳에서 수치와 데이터로 분석하는 프리미엄 LCK 아카이브 플랫폼입니다.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _FadeInSlideUp(
            delay: const Duration(milliseconds: 500),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 기록 탐색하기 (주요 행동 버튼 - 그라디언트 + 네온 글로우)
                _BounceAction(
                  onTap: onGuest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.neonGlow(
                        color: AppColors.accent,
                        blurRadius: 10,
                      ),
                    ),
                    child: Text(
                      '기록 탐색하기',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // 로그인 (글래스 아웃라인 버튼)
                _BounceAction(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      '로그인',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // 회원가입 (텍스트 버튼)
                _BounceAction(
                  onTap: onSignUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Text(
                      '회원가입',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary.withValues(
                          alpha: 0.4,
                        ),
                      ),
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

class LandingDashboardPreviewSection extends StatelessWidget {
  const LandingDashboardPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AuthGlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FadeInSlideUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              '바로 확인할 수 있는 정보',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 400),
            child: _LandingInfoRow(
              icon: Icons.shield_outlined,
              title: '팀별 순위와 전적',
              description: '현재 구단별 리그 순위, 시즌 전적, 최근 경기 성적 흐름을 실시간으로 확인합니다.',
            ),
          ),
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 450),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.divider),
            ),
          ),
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 500),
            child: _LandingInfoRow(
              icon: Icons.person_outline_rounded,
              title: '선수 기록 데이터',
              description: '선수명, 팀명, 포지션 기준으로 시즌 성적과 핵심 분석 수치를 빠르게 찾습니다.',
            ),
          ),
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 550),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.divider),
            ),
          ),
          const _FadeInSlideUp(
            delay: Duration(milliseconds: 600),
            child: _LandingInfoRow(
              icon: Icons.event_note_outlined,
              title: '경기 일정과 뉴스 피드',
              description: '다가오는 LCK 매치업과 중요한 e스포츠 최신 보도자료를 한눈에 모아봅니다.',
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingInfoRow extends StatelessWidget {
  const _LandingInfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorderMuted),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
