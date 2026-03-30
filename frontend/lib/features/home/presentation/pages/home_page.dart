import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../shared/models/news_article.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../matches/presentation/widgets/match_result_tile.dart';
import '../widgets/favorite_team_card.dart';
import '../widgets/headline_news_card.dart';
import '../widgets/key_player_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    final keyPlayers = MockLckData.playersForTeam(
      favoriteTeam.id,
    ).take(3).toList();
    final featuredNews = MockLckData.newsForTeam(
      favoriteTeam.id,
    ).take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        12,
        AppSpacing.screen,
        120,
      ),
      children: [
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.appTagline,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        FavoriteTeamCard(
          team: favoriteTeam,
          onTap: () => _openTeamDetail(context, favoriteTeam),
        ),
        const SizedBox(height: AppSpacing.section),
        const SectionHeader(title: '응원팀 최근 경기 결과'),
        const SizedBox(height: 14),
        ...favoriteTeam.recentMatches
            .take(2)
            .map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchResultTile(
                  match: match,
                  accentColor: favoriteTeam.color,
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.section - 4),
        const SectionHeader(title: '응원팀 주요 선수'),
        const SizedBox(height: 14),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: keyPlayers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final player = keyPlayers[index];
              return KeyPlayerCard(
                player: player,
                onTap: () => _openPlayerDetail(context, player),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        const SectionHeader(title: '이번 주 주요 뉴스'),
        const SizedBox(height: 14),
        ...featuredNews.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HeadlineNewsCard(
              article: article,
              onTagTap: (tag) => _handleTagTap(context, tag),
              onSourceTap: () => _showSourceLink(context, article),
            ),
          ),
        ),
      ],
    );
  }

  void _openTeamDetail(BuildContext context, TeamSummary team) {
    Navigator.of(context).pushNamed(AppRouter.teamDetail, arguments: team);
  }

  void _openPlayerDetail(BuildContext context, PlayerProfile player) {
    Navigator.of(context).pushNamed(AppRouter.playerDetail, arguments: player);
  }

  void _handleTagTap(BuildContext context, String tag) {
    final team = MockLckData.findTeamByTag(tag);
    if (team != null) {
      _openTeamDetail(context, team);
      return;
    }

    final player = MockLckData.findPlayerByTag(tag);
    if (player != null) {
      _openPlayerDetail(context, player);
    }
  }

  void _showSourceLink(BuildContext context, NewsArticle article) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('원문 링크 예시: ${article.link}')));
  }
}
