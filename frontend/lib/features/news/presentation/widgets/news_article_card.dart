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
      child: Ink(
        decoration: BoxDecoration(
          color: highlighted ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: highlighted
                ? AppColors.accent.withValues(alpha: 0.28)
                : AppColors.divider,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 18),
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
        if (highlighted) ...[
          const _FeaturedNewsBadge(),
          const SizedBox(height: 12),
        ],
        _NewsMetaRow(article: article),
        const SizedBox(height: 12),
        Text(
          article.title,
          maxLines: highlighted ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style:
              (highlighted
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.titleMedium)
                  ?.copyWith(height: 1.28),
        ),
        if (resolvedThumbnailUrl != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: highlighted ? 16 / 9 : 21 / 9,
              child: Image.network(
                resolvedThumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _NewsImageFallback(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          article.summaryOrPlaceholder,
          maxLines: highlighted ? 4 : 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                article.publisherOrSource,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('기사 열기'),
            ),
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
            const SizedBox(height: 10),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              article.summaryOrPlaceholder,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.publisherOrSource,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
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
              const SizedBox(width: 14),
              _CompactThumbnailImage(imageUrl: resolvedThumbnailUrl!),
            ],
          );
        }

        if (resolvedThumbnailUrl != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    resolvedThumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _NewsImageFallback(),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        color: AppColors.accentStrong.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentStrong.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              '주목 기사',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
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
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
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
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 112,
        height: 112,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _NewsImageFallback(),
        ),
      ),
    );
  }
}

class _NewsImageFallback extends StatelessWidget {
  const _NewsImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSecondary.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
