import 'package:flutter/material.dart';

import 'package:frontend/shared/models/news_article.dart';
import 'package:frontend/features/news/presentation/widgets/news_article_card.dart';

class HeadlineNewsCard extends StatelessWidget {
  const HeadlineNewsCard({
    required this.article,
    required this.onTap,
    super.key,
  });

  final NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NewsArticleCard(article: article, onTap: onTap, compact: true);
  }
}
