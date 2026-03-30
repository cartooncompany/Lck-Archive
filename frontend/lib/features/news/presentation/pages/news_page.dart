import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../shared/models/news_article.dart';
import '../widgets/news_article_card.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        12,
        AppSpacing.screen,
        120,
      ),
      children: [
        Text('이번 주 LCK 뉴스', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '최신 이슈와 팀/선수 태그를 중심으로 빠르게 탐색할 수 있습니다.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        ...MockLckData.news.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NewsArticleCard(
              article: article,
              onTagTap: (tag) => _handleTagTap(context, tag),
              onSourceTap: () => _showSourceLink(context, article),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTagTap(BuildContext context, String tag) {
    final team = MockLckData.findTeamByTag(tag);
    if (team != null) {
      Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
      return;
    }

    final player = MockLckData.findPlayerByTag(tag);
    if (player != null) {
      Navigator.of(
        context,
      ).pushNamed(AppRouter.playerDetail, arguments: player);
    }
  }

  void _showSourceLink(BuildContext context, NewsArticle article) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('원문 링크 예시: ${article.link}')));
  }
}
