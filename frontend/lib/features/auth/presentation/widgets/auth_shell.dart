import 'package:flutter/material.dart';

import 'auth_shared_widgets.dart';

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
      backgroundColor: AuthUiColors.canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= breakpoint;
          final horizontalPadding = isWide ? 32.0 : 20.0;

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AuthUiColors.canvasDeep,
                  AuthUiColors.canvas,
                  AuthUiColors.canvasSoft,
                ],
                stops: [0.0, 0.45, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(child: _AuthCanvasBackdrop()),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      28,
                      horizontalPadding,
                      36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: heroFlex, child: hero),
                                  const SizedBox(width: 40),
                                  Expanded(flex: panelFlex, child: panel),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  hero,
                                  const SizedBox(height: 28),
                                  panel,
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

class _AuthCanvasBackdrop extends StatelessWidget {
  const _AuthCanvasBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -1.0),
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  AuthUiColors.canvas,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -120,
          top: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2AD3FF).withValues(alpha: 0.10),
                  const Color(0xFF2AD3FF).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -100,
          bottom: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8CA7FF).withValues(alpha: 0.08),
                  const Color(0xFF8CA7FF).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _AuthCanvasPainter())),
      ],
    );
  }
}

class _AuthCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.05);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.08);

    for (double x = 32; x < size.width; x += 88) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 44; y < size.height; y += 96) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (double x = size.width * 0.12; x <= size.width * 0.44; x += 72) {
      canvas.drawCircle(Offset(x, size.height * 0.82), 1.4, dotPaint);
    }

    for (double y = size.height * 0.16; y <= size.height * 0.40; y += 78) {
      canvas.drawCircle(Offset(size.width * 0.84, y), 1.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
