import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../widgets/player_list_tile.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  static const List<String> _positions = [
    'ALL',
    'TOP',
    'JGL',
    'MID',
    'ADC',
    'SUP',
  ];

  String _query = '';
  String _selectedPosition = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = MockLckData.players.where((player) {
      final matchesQuery = _matchesPlayerQuery(player, _query);
      final matchesPosition =
          _selectedPosition == 'ALL' || player.position == _selectedPosition;
      return matchesQuery && matchesPosition;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        12,
        AppSpacing.screen,
        120,
      ),
      children: [
        Text('선수 기록', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '선수명, 팀명, 포지션으로 빠르게 탐색할 수 있습니다.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        AppSearchField(
          hintText: '선수명 또는 팀명 검색',
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _positions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final position = _positions[index];
              return ChoiceChip(
                label: Text(position),
                selected: _selectedPosition == position,
                onSelected: (_) => setState(() => _selectedPosition = position),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        ...filteredPlayers.map(
          (player) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlayerListTile(
              player: player,
              onTap: () => _openPlayer(context, player),
            ),
          ),
        ),
      ],
    );
  }

  void _openPlayer(BuildContext context, PlayerProfile player) {
    Navigator.of(context).pushNamed(AppRouter.playerDetail, arguments: player);
  }

  bool _matchesPlayerQuery(PlayerProfile player, String rawQuery) {
    final keyword = rawQuery.trim().toLowerCase();
    if (keyword.isEmpty) {
      return true;
    }

    final matchesName = player.name.toLowerCase().contains(keyword);
    return matchesName || _matchesTeamKeyword(player.teamName, keyword);
  }

  bool _matchesTeamKeyword(String teamName, String keyword) {
    final normalizedTeamName = teamName.toLowerCase();
    if (normalizedTeamName.startsWith(keyword)) {
      return true;
    }

    final words = normalizedTeamName
        .split(RegExp(r'[^a-z0-9]+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.any((word) => word.startsWith(keyword))) {
      return true;
    }

    final initials = words.map((word) => word[0]).join();
    return initials.startsWith(keyword);
  }
}
