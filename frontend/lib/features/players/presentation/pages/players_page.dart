import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
  Future<List<PlayerProfile>>? _playersFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playersFuture ??= _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayerProfile>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        final players = snapshot.data ?? const <PlayerProfile>[];

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
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                  _playersFuture = _loadPlayers();
                });
              },
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
                    onSelected: (_) => setState(() {
                      _selectedPosition = position;
                      _playersFuture = _loadPlayers();
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (snapshot.connectionState == ConnectionState.waiting &&
                players.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (players.isEmpty)
              _PlayersMessage(message: '검색 결과가 없습니다.')
            else
              ...players.map(
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
      },
    );
  }

  Future<List<PlayerProfile>> _loadPlayers() {
    return AppDependenciesScope.of(context).playersRepository.getPlayers(
      keyword: _query,
      position: _selectedPosition,
    );
  }

  void _openPlayer(BuildContext context, PlayerProfile player) {
    Navigator.of(context).pushNamed(AppRouter.playerDetail, arguments: player);
  }
}

class _PlayersMessage extends StatelessWidget {
  const _PlayersMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}
