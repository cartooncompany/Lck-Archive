import 'package:flutter/material.dart';

final class AuthUiColors {
  static const Color canvas = Color(0xFF0A0E18);
  static const Color canvasDeep = Color(0xFF060912);
  static const Color canvasSoft = Color(0xFF121A2B);
  static const Color panel = Colors.white;
  static const Color ink = Color(0xFF111111);
  static const Color inkSoft = Color(0xFF333333);
  static const Color muted = Color(0xFF7C7C7C);
  static const Color line = Color(0xFFE5E1DA);
  static const Color lineStrong = Color(0xFFCAC4BA);
  static const Color heroSurface = Color(0xFF131B2C);
  static const Color heroSurfaceStrong = Color(0xFF1B2436);
  static const Color heroLine = Color(0xFF283247);
  static const Color heroText = Color(0xFFF7F9FC);
  static const Color heroMuted = Color(0xFFB2BDD0);
}

class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(28),
    this.radius = 30,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuthUiColors.heroSurfaceStrong.withValues(alpha: 0.98),
            AuthUiColors.heroSurface.withValues(alpha: 0.96),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AuthSectionBadge extends StatelessWidget {
  const AuthSectionBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AuthUiColors.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class AuthFeaturePill extends StatelessWidget {
  const AuthFeaturePill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AuthUiColors.heroText,
          fontWeight: FontWeight.w600,
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: AuthUiColors.heroText),
              ),
            if (icon != null) const SizedBox(height: 16),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: AuthUiColors.heroMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
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
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 12, color: AuthUiColors.heroText),
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

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuthUiColors.ink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AuthUiColors.ink,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
