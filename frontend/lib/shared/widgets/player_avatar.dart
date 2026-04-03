import 'package:flutter/material.dart';

import '../../core/network/media_url_resolver.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    required this.name,
    required this.size,
    required this.accentColor,
    super.key,
    this.profileImageUrl,
    this.backgroundColor,
    this.borderRadius = 999,
    this.textStyle,
  });

  final String name;
  final String? profileImageUrl;
  final double size;
  final Color accentColor;
  final Color? backgroundColor;
  final double borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = resolveMediaUrl(profileImageUrl);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? accentColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedImageUrl != null
          ? Image.network(
              resolvedImageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => _FallbackInitial(
                name: name,
                accentColor: accentColor,
                textStyle: textStyle,
              ),
            )
          : _FallbackInitial(
              name: name,
              accentColor: accentColor,
              textStyle: textStyle,
            ),
    );
  }
}

class _FallbackInitial extends StatelessWidget {
  const _FallbackInitial({
    required this.name,
    required this.accentColor,
    required this.textStyle,
  });

  final String name;
  final Color accentColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1);
    return Text(
      initial,
      style:
          textStyle ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
