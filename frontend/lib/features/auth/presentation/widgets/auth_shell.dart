import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';

export 'auth_form_widgets.dart';
export 'auth_shared_widgets.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    required this.hero,
    required this.panel,
    super.key,
    this.breakpoint = 980,
    this.maxWidth = 1160,
    this.heroFlex = 11,
    this.panelFlex = 9,
  });

  final Widget hero;
  final Widget panel;
  final double breakpoint;
  final double maxWidth;
  final int heroFlex;
  final int panelFlex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= breakpoint;
          final horizontalPadding = isWide ? 40.0 : 20.0;
          final verticalPadding = isWide ? 40.0 : 24.0;
          final minContentHeight =
              constraints.maxHeight -
              verticalPadding * 2 -
              MediaQuery.paddingOf(context).vertical;

          return Stack(
            children: [
              // 1. 둥실 떠다니는 네온 글로우 오브 배경
              const Positioned.fill(
                child: IgnorePointer(child: _AnimatedGlowOrbs()),
              ),

              // 2. 글래스모피즘 분위기를 극대화하는 미세한 전체 격자 노이즈 또는 블러 레이어
              Positioned.fill(
                child: IgnorePointer(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              // 3. 실제 컨텐츠 영역
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding + 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minContentHeight > 0
                              ? minContentHeight
                              : 0,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: heroFlex, child: hero),
                                  const SizedBox(width: 48),
                                  Expanded(flex: panelFlex, child: panel),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  hero,
                                  const SizedBox(height: 36),
                                  panel,
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 천천히 부드럽게 화면을 떠다니며 프리미엄 네온 감성을 극대화하는 애니메이티드 오비 배경
class _AnimatedGlowOrbs extends StatefulWidget {
  const _AnimatedGlowOrbs();

  @override
  State<_AnimatedGlowOrbs> createState() => _AnimatedGlowOrbsState();
}

class _AnimatedGlowOrbsState extends State<_AnimatedGlowOrbs>
    with TickerProviderStateMixin {
  late final AnimationController _cyanController;
  late final AnimationController _blueController;
  late final AnimationController _purpleController;

  @override
  void initState() {
    super.initState();
    // 각 오비마다 다른 주기로 천천히 움직이도록 애니메이션 컨트롤러 설정
    _cyanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);

    _blueController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat(reverse: true);

    _purpleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cyanController.dispose();
    _blueController.dispose();
    _purpleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cyanController,
        _blueController,
        _purpleController,
      ]),
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        if (size.width == 0 || size.height == 0) return const SizedBox.shrink();

        // 시간에 따라 구형 오브들이 떠돌아다닐 위치 계산 (삼각함수 활용)
        final cyanVal = _cyanController.value * 2 * math.pi;
        final blueVal = _blueController.value * 2 * math.pi;
        final purpleVal = _purpleController.value * 2 * math.pi;

        // 화면 비율 기준 상대적 포지셔닝
        final cyanX = size.width * 0.15 + math.sin(cyanVal) * 50;
        final cyanY = size.height * 0.2 + math.cos(cyanVal) * 60;

        final blueX = size.width * 0.75 + math.cos(blueVal) * 70;
        final blueY = size.height * 0.65 + math.sin(blueVal) * 50;

        final purpleX = size.width * 0.45 + math.sin(purpleVal * 1.5) * 60;
        final purpleY = size.height * 0.4 + math.cos(purpleVal) * 40;

        return Stack(
          children: [
            // Cyan Orb (왼쪽 위 부근)
            Positioned(
              left: cyanX - 200,
              top: cyanY - 200,
              child: _GlowCircle(
                size: 400,
                color: AppColors.accent.withValues(alpha: 0.18),
              ),
            ),
            // Blue Orb (오른쪽 아래 부근)
            Positioned(
              left: blueX - 250,
              top: blueY - 250,
              child: _GlowCircle(
                size: 500,
                color: AppColors.accentStrong.withValues(alpha: 0.15),
              ),
            ),
            // Purple Orb (중앙 우측 부근)
            Positioned(
              left: purpleX - 150,
              top: purpleY - 150,
              child: _GlowCircle(
                size: 300,
                color: const Color(0xFF9F5CFF).withValues(alpha: 0.14),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.3), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
