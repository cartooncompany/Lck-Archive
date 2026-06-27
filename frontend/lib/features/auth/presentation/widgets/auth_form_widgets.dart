import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';

class AuthPhoneFrame extends StatelessWidget {
  const AuthPhoneFrame({
    required this.header,
    required this.body,
    super.key,
    this.maxWidth = 430,
    this.headerHeight = 104,
    this.overlap = 0,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.75),
                    AppColors.surfaceElevated.withValues(alpha: 0.55),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: -4,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.02),
                    blurRadius: 50,
                  ),
                ],
              ),
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
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                            child: header,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: overlap),
                    child: body,
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

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.children,
    super.key,
    this.title,
    this.description,
    this.errorMessage,
    this.footer,
    this.centerTitle = false,
    this.padding = const EdgeInsets.fromLTRB(28, 28, 28, 32),
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
    // 이제 프리미엄 다크 모드 테마를 생성하여 폼 내부에 강제합니다.
    final theme = _buildDarkAuthTheme(Theme.of(context));
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
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
            if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
              AuthErrorBanner(message: errorMessage!),
              const SizedBox(height: 18),
            ],
            ...children,
            if (footer != null) ...[const SizedBox(height: 24), footer!],
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
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData _buildDarkAuthTheme(ThemeData base) {
  final textTheme = base.textTheme.apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return base.copyWith(
    brightness: Brightness.dark,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      onSurface: AppColors.textPrimary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceElevated.withValues(alpha: 0.4),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      helperStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppColors.divider),
      border: border(AppColors.divider),
      focusedBorder: border(AppColors.accent, width: 1.5),
      errorBorder: border(AppColors.danger.withValues(alpha: 0.5), width: 1.2),
      focusedErrorBorder: border(AppColors.danger, width: 1.5),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
    // 다크 네온의 미려한 메쉬 그라디언트 느낌 연출
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0C1224), Color(0xFF182341)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(baseRect);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.accent.withValues(alpha: 0.12);

    canvas.drawRect(baseRect, backgroundPaint);

    // 심심하지 않게 사이버네틱 앵글 라인 한 줄 드로잉
    canvas.drawLine(
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.6, size.height * 0.9),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.9),
      Offset(size.width * 0.7, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
