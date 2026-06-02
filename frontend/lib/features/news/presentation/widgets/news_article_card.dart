import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/media_url_resolver.dart';
import '../../../../shared/models/news_article.dart';

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({
    required this.article,
    required this.onTap,
    this.compact = false,
    this.highlighted = false,
    super.key,
  });

  final NewsArticle article;
  final VoidCallback onTap;
  final bool compact;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final resolvedThumbnailUrl = resolveMediaUrl(article.thumbnailUrl);
    final borderRadius = BorderRadius.circular(highlighted ? 24 : 22);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: highlighted
                    ? [
                        AppColors.surfaceElevated.withValues(alpha: 0.8),
                        AppColors.surface.withValues(alpha: 0.6),
                      ]
                    : [
                        AppColors.surface.withValues(alpha: 0.65),
                        AppColors.surfaceMuted.withValues(alpha: 0.45),
                      ],
              ),
              borderRadius: borderRadius,
              border: Border.all(
                color: highlighted
                    ? AppColors.accent.withValues(alpha: 0.45)
                    : AppColors.glassBorderMuted,
                width: highlighted ? 1.5 : 1.0,
              ),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.04),
                        blurRadius: 40,
                        spreadRadius: -4,
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              hoverColor: AppColors.accent.withValues(alpha: 0.04),
              splashColor: AppColors.accent.withValues(alpha: 0.08),
              highlightColor: AppColors.accent.withValues(alpha: 0.06),
              child: Padding(
                padding: EdgeInsets.all(compact ? 16 : 20),
                child: compact
                    ? _CompactNewsCardContent(
                        article: article,
                        resolvedThumbnailUrl: resolvedThumbnailUrl,
                      )
                    : _RegularNewsCardContent(
                        article: article,
                        highlighted: highlighted,
                        resolvedThumbnailUrl: resolvedThumbnailUrl,
                        onTap: onTap,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegularNewsCardContent extends StatelessWidget {
  const _RegularNewsCardContent({
    required this.article,
    required this.highlighted,
    required this.resolvedThumbnailUrl,
    required this.onTap,
  });

  final NewsArticle article;
  final bool highlighted;
  final String? resolvedThumbnailUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (highlighted) ...[
              const _FeaturedNewsBadge(),
              const SizedBox(width: 8),
            ],
            Expanded(child: _NewsMetaRow(article: article)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          article.title,
          maxLines: highlighted ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style:
              (highlighted
                      ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        )
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ))
                  ?.copyWith(height: 1.32, letterSpacing: -0.3),
        ),
        if (resolvedThumbnailUrl != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: highlighted ? 16 / 9 : 21 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    resolvedThumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _NewsImageFallback(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          article.summaryOrPlaceholder,
          maxLines: highlighted ? 4 : 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.48,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                article.publisherOrSource,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _HoverTextButton(onPressed: onTap, label: '기사 열기'),
          ],
        ),
      ],
    );
  }
}

class _CompactNewsCardContent extends StatelessWidget {
  const _CompactNewsCardContent({
    required this.article,
    required this.resolvedThumbnailUrl,
  });

  final NewsArticle article;
  final String? resolvedThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideImage =
            resolvedThumbnailUrl != null && constraints.maxWidth >= 360;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsMetaRow(article: article),
            const SizedBox(height: 12),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                height: 1.32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.summaryOrPlaceholder,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.publisherOrSource,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        );

        if (useSideImage) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 16),
              _CompactThumbnailImage(imageUrl: resolvedThumbnailUrl!),
            ],
          );
        }

        if (resolvedThumbnailUrl != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        resolvedThumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _NewsImageFallback(),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }
}

class _NewsMetaRow extends StatelessWidget {
  const _NewsMetaRow({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: _NewsSourceBadge(label: article.sourceLabel)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            article.publishedLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedNewsBadge extends StatelessWidget {
  const _FeaturedNewsBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: AppColors.neonGlow(color: AppColors.danger, blurRadius: 6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 13, color: AppColors.danger),
            const SizedBox(width: 4),
            Text(
              '주목 기사',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsSourceBadge extends StatelessWidget {
  const _NewsSourceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: AppColors.neonGlow(color: AppColors.accent, blurRadius: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _CompactThumbnailImage extends StatelessWidget {
  const _CompactThumbnailImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _NewsImageFallback(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsImageFallback extends StatelessWidget {
  const _NewsImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated.withValues(alpha: 0.95),
            AppColors.surfaceMuted.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColors.accent.withValues(alpha: 0.4),
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              'LCK ARCHIVE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.accent.withValues(alpha: 0.35),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverTextButton extends StatefulWidget {
  const _HoverTextButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _isHovered
              ? AppColors.accent
              : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          backgroundColor: _isHovered
              ? AppColors.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _isHovered
                  ? AppColors.accent.withValues(alpha: 0.25)
                  : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        onPressed: widget.onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: _isHovered ? AppColors.accent : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
