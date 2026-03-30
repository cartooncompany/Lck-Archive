import 'package:flutter/material.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/utils/mock_lck_data.dart';
import '../../../../shared/models/lck_match_result.dart';
import '../../../../shared/models/team_summary.dart';
import '../datasource/teams_remote_data_source.dart';
import '../dto/team_match_dto.dart';
import '../dto/team_summary_dto.dart';

class TeamsRepository {
  TeamsRepository({required TeamsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TeamsRemoteDataSource _remoteDataSource;
  final Map<String, TeamSummary> _teamCache = <String, TeamSummary>{};

  Future<List<TeamSummary>> getTeams({String? keyword, int limit = 100}) async {
    try {
      final response = await _remoteDataSource.getTeams(
        keyword: keyword,
        limit: limit,
      );
      final teams = response.items.map(_mapSummary).toList();
      _rememberTeams(teams);
      return teams;
    } catch (_) {
      final fallback = MockLckData.teams.where((team) {
        final normalizedKeyword = keyword?.trim().toLowerCase() ?? '';
        if (normalizedKeyword.isEmpty) {
          return true;
        }
        return team.name.toLowerCase().contains(normalizedKeyword) ||
            team.initials.toLowerCase().contains(normalizedKeyword);
      }).toList();
      _rememberTeams(fallback);
      return fallback;
    }
  }

  Future<TeamSummary> getInitialFavoriteTeam() async {
    final teams = await getTeams();
    if (teams.isEmpty) {
      return MockLckData.defaultFavoriteTeam;
    }

    for (final team in teams) {
      if (team.initials.toUpperCase() == 'T1' || team.name.toUpperCase() == 'T1') {
        return team;
      }
    }

    return teams.first;
  }

  Future<TeamSummary> getTeam(String id) async {
    try {
      final detail = await _remoteDataSource.getTeamDetail(id);
      final matches = await _remoteDataSource.getTeamMatches(
        id,
        limit: 5,
        status: 'COMPLETED',
      );
      final team = _mapSummary(
        detail,
        recentForm: detail.recentForm,
        recentMatches: matches.items
            .map((match) => _mapMatch(match, teamId: id))
            .toList(),
      );
      _teamCache[team.id] = team;
      return team;
    } catch (_) {
      final cachedTeam = _teamCache[id];
      if (cachedTeam != null) {
        return cachedTeam;
      }

      final fallbackTeam = MockLckData.findTeam(id: id);
      if (fallbackTeam != null) {
        return fallbackTeam;
      }

      throw const AppFailure('팀 정보를 불러오지 못했습니다.');
    }
  }

  Future<TeamSummary?> findTeamByTag(String tag) async {
    final normalizedTag = tag.trim().toLowerCase();
    if (normalizedTag.isEmpty) {
      return null;
    }

    for (final team in _teamCache.values) {
      if (_matchesTag(team, normalizedTag)) {
        return team;
      }
    }

    final teams = await getTeams(keyword: tag);
    for (final team in teams) {
      if (_matchesTag(team, normalizedTag)) {
        return team;
      }
    }

    return MockLckData.findTeam(name: tag, shortName: tag);
  }

  void _rememberTeams(List<TeamSummary> teams) {
    for (final team in teams) {
      _teamCache[team.id] = team;
    }
  }

  TeamSummary _mapSummary(
    TeamSummaryDto dto, {
    List<String>? recentForm,
    List<LckMatchResult>? recentMatches,
  }) {
    final fallback = MockLckData.findTeam(
      id: dto.id,
      name: dto.name,
      shortName: dto.shortName,
    );
    final resolvedRecentMatches = recentMatches ?? fallback?.recentMatches ?? const [];

    return TeamSummary(
      id: dto.id,
      name: dto.name,
      initials: dto.shortName,
      rank: dto.rank ?? fallback?.rank ?? 0,
      seasonRecord: '${dto.wins}-${dto.losses}',
      setRecord: _formatDifferential(dto.setDifferential),
      summary:
          fallback?.summary ?? '${dto.name}의 최근 경기 흐름과 시즌 기록을 확인할 수 있습니다.',
      recentForm: recentForm ?? fallback?.recentForm ?? const [],
      recentMatches: resolvedRecentMatches,
      color: fallback?.color ?? _fallbackColor(dto.shortName),
    );
  }

  LckMatchResult _mapMatch(TeamMatchDto dto, {required String teamId}) {
    final isHomeTeam = dto.homeTeam.id == teamId;
    final opponent = isHomeTeam ? dto.awayTeam : dto.homeTeam;
    final teamScore = isHomeTeam ? dto.score.home : dto.score.away;
    final opponentScore = isHomeTeam ? dto.score.away : dto.score.home;

    return LckMatchResult(
      opponent: opponent.name,
      playedAt: dto.scheduledAt,
      outcome: _matchOutcome(dto, teamId: teamId),
      score: '$teamScore:$opponentScore',
      note: '${dto.split} ${dto.stage} · ${_statusLabel(dto.status)}',
    );
  }

  String _matchOutcome(TeamMatchDto dto, {required String teamId}) {
    if (dto.status != 'COMPLETED') {
      return dto.status == 'CANCELED' ? '취소' : '예정';
    }

    if (dto.winner != null) {
      return dto.winner!.id == teamId ? 'W' : 'L';
    }

    final isHomeTeam = dto.homeTeam.id == teamId;
    final teamScore = isHomeTeam ? dto.score.home : dto.score.away;
    final opponentScore = isHomeTeam ? dto.score.away : dto.score.home;
    return teamScore >= opponentScore ? 'W' : 'L';
  }

  bool _matchesTag(TeamSummary team, String tag) {
    return team.name.toLowerCase() == tag || team.initials.toLowerCase() == tag;
  }

  String _formatDifferential(int value) {
    return value > 0 ? '+$value' : '$value';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return '경기 종료';
      case 'CANCELED':
        return '경기 취소';
      default:
        return '경기 예정';
    }
  }

  Color _fallbackColor(String seed) {
    const palette = <Color>[
      Color(0xFFE74C3C),
      Color(0xFFFFC107),
      Color(0xFFFF7A00),
      Color(0xFF5A7CFF),
      Color(0xFF1E88E5),
      Color(0xFF22A06B),
    ];
    final index = seed.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return palette[index % palette.length];
  }
}
