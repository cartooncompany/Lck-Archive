import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'auth_shared_widgets.dart';

class AuthPhoneFrame extends StatelessWidget {
  const AuthPhoneFrame({
    required this.header,
    required this.body,
    super.key,
    this.maxWidth = 360,
    this.headerHeight = 122,
    this.overlap = 28,
  });

  final Widget header;
  final Widget body;
  final double maxWidth;
  final double headerHeight;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _AuthPatternArt()),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                          child: header,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: overlap),
                  child: Transform.translate(
                    offset: Offset(0, -overlap),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                      ),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.children,
    super.key,
    this.title,
    this.description,
    this.errorMessage,
    this.footer,
    this.centerTitle = false,
    this.padding = const EdgeInsets.fromLTRB(22, 24, 22, 28),
  });

  final String? title;
  final String? description;
  final String? errorMessage;
  final List<Widget> children;
  final Widget? footer;
  final bool centerTitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = _buildLightAuthTheme(Theme.of(context));
    final textTheme = theme.textTheme;

    return Theme(
      data: theme,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: textTheme.headlineSmall?.copyWith(
                  color: AuthUiColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  description!,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AuthUiColors.muted,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
              const SizedBox(height: 22),
            ],
            if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
              AuthErrorBanner(message: errorMessage!),
              const SizedBox(height: 18),
            ],
            ...children,
            if (footer != null) ...[const SizedBox(height: 18), footer!],
          ],
        ),
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.danger,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

ThemeData _buildLightAuthTheme(ThemeData base) {
  final textTheme = base.textTheme.apply(
    bodyColor: AuthUiColors.ink,
    displayColor: AuthUiColors.ink,
  );

  final underline = UnderlineInputBorder(
    borderSide: const BorderSide(color: AuthUiColors.line),
    borderRadius: BorderRadius.circular(0),
  );

  return base.copyWith(
    brightness: Brightness.light,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: AuthUiColors.ink,
      onPrimary: Colors.white,
      onSurface: AuthUiColors.ink,
      surface: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: false,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AuthUiColors.inkSoft,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AuthUiColors.muted,
        fontSize: 13,
      ),
      helperStyle: textTheme.bodySmall?.copyWith(
        color: AuthUiColors.muted,
        fontSize: 12,
      ),
      contentPadding: const EdgeInsets.only(top: 6, bottom: 10),
      enabledBorder: underline,
      border: underline,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AuthUiColors.ink, width: 1.2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.danger.withValues(alpha: 0.60),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.danger, width: 1.2),
      ),
      prefixIconColor: AuthUiColors.muted,
      suffixIconColor: AuthUiColors.muted,
    ),
    dividerTheme: const DividerThemeData(
      color: AuthUiColors.line,
      thickness: 1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AuthUiColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _AuthPatternArt extends StatelessWidget {
  const _AuthPatternArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AuthPatternPainter());
  }
}

class _AuthPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseRect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0B0D12), Color(0xFF151A24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(baseRect);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08);
    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.10);

    canvas.drawRect(baseRect, backgroundPaint);

    for (double x = -size.height; x < size.width + size.height; x += 26) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.7, size.height),
        linePaint,
      );
    }

    final barWidth = math.min(size.width * 0.18, 64.0);
    final top = size.height * 0.22;
    for (int index = 0; index < 3; index++) {
      final left = 18 + (barWidth + 8) * index;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, 8),
          const Radius.circular(999),
        ),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
