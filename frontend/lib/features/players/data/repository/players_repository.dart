import 'package:flutter/material.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../shared/models/player_profile.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../teams/data/repository/teams_repository.dart';
import '../datasource/players_remote_data_source.dart';
import '../dto/player_detail_dto.dart';
import '../dto/player_summary_dto.dart';

class PlayersRepository {
  PlayersRepository({
    required PlayersRemoteDataSource remoteDataSource,
    required TeamsRepository teamsRepository,
  }) : _remoteDataSource = remoteDataSource,
       _teamsRepository = teamsRepository;

  final PlayersRemoteDataSource _remoteDataSource;
  final TeamsRepository _teamsRepository;
  final Map<String, PlayerProfile> _playerCache = <String, PlayerProfile>{};

  Future<List<PlayerProfile>> getPlayers({
    String? keyword,
    String? position,
    String? teamId,
    int limit = 100,
  }) async {
    final normalizedKeyword = keyword?.trim();
    final apiPosition = _toApiPosition(position);

    try {
      final response = await _remoteDataSource.getPlayers(
        keyword: normalizedKeyword,
        position: apiPosition,
        teamId: teamId,
        limit: limit,
      );
      final playersById = <String, PlayerProfile>{
        for (final dto in response.items) dto.id: _mapSummary(dto),
      };

      if (teamId == null && normalizedKeyword != null && normalizedKeyword.isNotEmpty) {
        final matchingTeams = await _teamsRepository.getTeams(
          keyword: normalizedKeyword,
          limit: limit,
        );
        for (final team in matchingTeams.where(
          (item) => _matchesTeamKeyword(item, normalizedKeyword),
        )) {
          final teamPlayers = await _remoteDataSource.getPlayers(
            teamId: team.id,
            position: apiPosition,
            limit: limit,
          );
          for (final dto in teamPlayers.items) {
            playersById[dto.id] = _mapSummary(dto);
          }
        }
      }

      final players = playersById.values.toList()
        ..sort((left, right) {
          final teamComparison = left.teamName.compareTo(right.teamName);
          if (teamComparison != 0) {
            return teamComparison;
          }
          return left.name.compareTo(right.name);
        });
      _rememberPlayers(players);
      return players;
    } catch (_) {
      final fallback = _fallbackPlayers(
        keyword: normalizedKeyword,
        position: position,
        teamId: teamId,
      );
      _rememberPlayers(fallback);
      return fallback;
    }
  }

  Future<PlayerProfile> getPlayer(String id) async {
    try {
      final detail = await _remoteDataSource.getPlayerDetail(id);
      final player = _mapDetail(detail);
      _playerCache[player.id] = player;
      return player;
    } catch (_) {
      final cachedPlayer = _playerCache[id];
      if (cachedPlayer != null) {
        return cachedPlayer;
      }

      final fallbackPlayer = MockLckData.findPlayer(id: id);
      if (fallbackPlayer != null) {
        return fallbackPlayer;
      }

      throw const AppFailure('선수 정보를 불러오지 못했습니다.');
    }
  }

  Future<PlayerProfile?> findPlayerByTag(String tag) async {
    final normalizedTag = tag.trim().toLowerCase();
    if (normalizedTag.isEmpty) {
      return null;
    }

    for (final player in _playerCache.values) {
      if (player.name.toLowerCase() == normalizedTag) {
        return player;
      }
    }

    final players = await getPlayers(keyword: tag);
    for (final player in players) {
      if (player.name.toLowerCase() == normalizedTag) {
        return player;
      }
    }

    return MockLckData.findPlayer(name: tag);
  }

  void _rememberPlayers(List<PlayerProfile> players) {
    for (final player in players) {
      _playerCache[player.id] = player;
    }
  }

  PlayerProfile _mapSummary(PlayerSummaryDto dto) {
    final fallbackPlayer = MockLckData.findPlayer(id: dto.id, name: dto.name);
    final fallbackTeam = MockLckData.findTeam(
      id: dto.team?.id,
      name: dto.team?.name,
      shortName: dto.team?.shortName,
    );
    final teamName =
        dto.team?.name ?? fallbackPlayer?.teamName ?? dto.team?.shortName ?? '소속 팀 미상';

    return PlayerProfile(
      id: dto.id,
      name: dto.name,
      teamId: dto.team?.id ?? fallbackPlayer?.teamId ?? '',
      teamName: teamName,
      position: _displayPosition(dto.position),
      seasonMatches: dto.recentMatchCount,
      headline:
          fallbackPlayer?.headline ??
          '$teamName 소속 ${_displayPosition(dto.position)} 포지션 선수입니다.',
      keyStats: fallbackPlayer?.keyStats ?? const <String, String>{},
      recentAppearances:
          fallbackPlayer?.recentAppearances ?? const <PlayerMatchAppearance>[],
      teamColor:
          fallbackTeam?.color ??
          fallbackPlayer?.teamColor ??
          _fallbackColor(dto.team?.shortName ?? dto.name),
    );
  }

  PlayerProfile _mapDetail(PlayerDetailDto dto) {
    final summary = _mapSummary(dto);
    return summary.copyWith(
      realName: dto.realName,
      nationality: dto.nationality,
      birthDate: dto.birthDate,
    );
  }

  List<PlayerProfile> _fallbackPlayers({
    String? keyword,
    String? position,
    String? teamId,
  }) {
    final normalizedKeyword = keyword?.trim().toLowerCase() ?? '';
    final normalizedPosition = position?.trim().toUpperCase() ?? 'ALL';

    return MockLckData.players.where((player) {
      final matchesTeam = teamId == null || player.teamId == teamId;
      final matchesPosition =
          normalizedPosition == 'ALL' ||
          normalizedPosition.isEmpty ||
          player.position == normalizedPosition;
      final matchesKeyword =
          normalizedKeyword.isEmpty ||
          player.name.toLowerCase().contains(normalizedKeyword) ||
          _matchesTeamNameText(player.teamName, normalizedKeyword);
      return matchesTeam && matchesPosition && matchesKeyword;
    }).toList();
  }

  bool _matchesTeamKeyword(TeamSummary team, String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    return _matchesTeamNameText(team.name, normalizedKeyword) ||
        team.initials.toLowerCase().startsWith(normalizedKeyword);
  }

  bool _matchesTeamNameText(String teamName, String keyword) {
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

  String? _toApiPosition(String? position) {
    final normalizedPosition = position?.trim().toUpperCase();
    switch (normalizedPosition) {
      case null:
      case '':
      case 'ALL':
        return null;
      case 'JGL':
        return 'JUNGLE';
      case 'SUP':
        return 'SUPPORT';
      default:
        return normalizedPosition;
    }
  }

  String _displayPosition(String position) {
    switch (position.toUpperCase()) {
      case 'JUNGLE':
        return 'JGL';
      case 'SUPPORT':
        return 'SUP';
      default:
        return position.toUpperCase();
    }
  }

  Color _fallbackColor(String seed) {
    const palette = <Color>[
      Color(0xFFE74C3C),
      Color(0xFFFFC107),
      Color(0xFF5A7CFF),
      Color(0xFF22A06B),
      Color(0xFF1E88E5),
    ];
    final index = seed.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return palette[index % palette.length];
  }
}
