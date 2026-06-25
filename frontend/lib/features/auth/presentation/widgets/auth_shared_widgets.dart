import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

final class AuthUiColors {
  static const Color canvas = AppColors.background;
  static const Color canvasDeep = Color(0xFF070A14);
  static const Color canvasSoft = AppColors.surface;
  static const Color panel = Colors.white;
  static const Color panelSoft = Color(0xFFF6F8FC);
  static const Color ink = Color(0xFF101828);
  static const Color inkSoft = Color(0xFF344054);
  static const Color muted = Color(0xFF667085);
  static const Color line = Color(0xFFE4E9F2);
  static const Color lineStrong = Color(0xFFC7D0DF);
  static const Color heroSurface = AppColors.surface;
  static const Color heroSurfaceStrong = AppColors.surfaceElevated;
  static const Color heroLine = AppColors.divider;
  static const Color heroText = AppColors.textPrimary;
  static const Color heroMuted = AppColors.textSecondary;
  static const Color accent = AppColors.accent;
  static const Color accentStrong = AppColors.accentStrong;
}

class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(32),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.65),
                AppColors.surfaceElevated.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.glassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.03),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthSectionBadge extends StatelessWidget {
  const AuthSectionBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AuthUiColors.heroSurfaceStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AuthUiColors.heroLine),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AuthUiColors.heroMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}


class AuthMetricCard extends StatelessWidget {
  const AuthMetricCard({
    required this.label,
    required this.value,
    required this.description,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthUiColors.heroSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AuthUiColors.heroLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AuthUiColors.heroSurfaceStrong,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AuthUiColors.heroMuted),
              ),
            if (icon != null) const SizedBox(height: 14),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: AuthUiColors.heroMuted,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: AuthUiColors.heroText,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: AuthUiColors.heroMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthBulletPoint extends StatelessWidget {
  const AuthBulletPoint({
    required this.title,
    required this.description,
    this.icon = Icons.circle,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AuthUiColors.heroSurfaceStrong,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AuthUiColors.heroMuted),
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
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuthUiColors.heroMuted,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatefulWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasIcon = widget.icon != null;
    final isEnabled = widget.onPressed != null;

    final child = widget.icon == null
        ? Text(widget.label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isEnabled ? null : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: isEnabled
                ? AppColors.neonGlow(color: AppColors.accent, blurRadius: 8)
                : null,
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: TextStyle(
              color: isEnabled ? AppColors.background : AppColors.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: isEnabled ? AppColors.background : AppColors.textMuted,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthPreviewFieldLine extends StatelessWidget {
  const AuthPreviewFieldLine({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AuthUiColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AuthUiColors.muted),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AuthUiColors.line),
      ],
    );
  }
}

class AuthLogoMark extends StatelessWidget {
  const AuthLogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.neonGlow(
                color: AppColors.accent,
                blurRadius: 10,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.primaryGradient,
            ).createShader(bounds),
            child: Text(
              'LCK ARCHIVE',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
