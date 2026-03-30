import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/models/news_article.dart';

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({
    required this.article,
    required this.onTagTap,
    required this.onSourceTap,
    super.key,
  });

  final NewsArticle article;
  final ValueChanged<String> onTagTap;
  final VoidCallback onSourceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.publishedAt.toKoreanDate(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(article.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            article.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: article.tags
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () => onTagTap(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                article.sourceLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.accent),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSourceTap,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('원문 링크'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
