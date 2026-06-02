import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/network/media_url_resolver.dart';

class TeamLogo extends StatelessWidget {
  static const Color defaultBackgroundColor = AppColors.surface;

  const TeamLogo({
    required this.initials,
    required this.size,
    super.key,
    this.logoUrl,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.textStyle,
    this.padding = 8,
  });

  final String initials;
  final String? logoUrl;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final resolvedLogoUrl = resolveMediaUrl(logoUrl);
    final borderCol = borderColor ?? AppColors.glassBorderMuted;
    final glowColor = foregroundColor ?? AppColors.accent;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: foregroundColor != null
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.15),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedLogoUrl != null
          ? Padding(
              padding: EdgeInsets.all(padding),
              child: Image.network(
                resolvedLogoUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => _FallbackLabel(
                  initials: initials,
                  foregroundColor: foregroundColor,
                  textStyle: textStyle,
                ),
              ),
            )
          : _FallbackLabel(
              initials: initials,
              foregroundColor: foregroundColor,
              textStyle: textStyle,
            ),
    );
  }
}

class _FallbackLabel extends StatelessWidget {
  const _FallbackLabel({
    required this.initials,
    required this.foregroundColor,
    required this.textStyle,
  });

  final String initials;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          textStyle ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
