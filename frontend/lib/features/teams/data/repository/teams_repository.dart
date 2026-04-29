import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/models/lck_match_result.dart';
import '../../../../shared/models/team_summary.dart';
import '../datasource/teams_remote_data_source.dart';
import '../dto/team_match_dto.dart';
import '../dto/team_summary_dto.dart';

class TeamsRepository {
  TeamsRepository({
    required TeamsRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  final TeamsRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;
  final Map<String, TeamSummary> _teamCache = <String, TeamSummary>{};
  Future<void>? _hydrateFuture;

  static const String _storageKey = 'teams_repository.cache.v1';
  static const String _favoriteTeamStorageKey =
      'teams_repository.favorite_team_id.v1';

  Future<List<TeamSummary>> getTeams({String? keyword, int limit = 100}) async {
    await _ensureHydrated();

    try {
      final response = await _remoteDataSource.getTeams(
        keyword: keyword,
        limit: limit,
      );
      final teams = response.items.map(_mapSummary).toList();
      _rememberTeams(teams);
      await _persistCache();
      return teams;
    } catch (_) {
      final cachedTeams = _cachedTeams(keyword: keyword);
      if (cachedTeams.isNotEmpty) {
        return cachedTeams;
      }
      return const <TeamSummary>[];
    }
  }

  Future<TeamSummary?> getInitialFavoriteTeam() async {
    await _ensureHydrated();
    final savedFavoriteTeamId = await _localStorage.readString(
      _favoriteTeamStorageKey,
    );

    if (savedFavoriteTeamId != null && savedFavoriteTeamId.trim().isNotEmpty) {
      final cachedTeam = _teamCache[savedFavoriteTeamId];
      if (cachedTeam != null) {
        return cachedTeam;
      }

      try {
        final savedTeam = await getTeam(savedFavoriteTeamId);
        await saveFavoriteTeamId(savedTeam.id);
        return savedTeam;
      } catch (_) {
        // Fall through to default selection.
      }
    }

    final teams = await getTeams();
    if (teams.isEmpty) {
      return null;
    }

    for (final team in teams) {
      if (team.initials.toUpperCase() == 'T1' ||
          team.name.toUpperCase() == 'T1') {
        await saveFavoriteTeamId(team.id);
        return team;
      }
    }

    await saveFavoriteTeamId(teams.first.id);
    return teams.first;
  }

  Future<void> saveFavoriteTeamId(String teamId) async {
    await _localStorage.writeString(_favoriteTeamStorageKey, teamId);
  }

  Future<TeamSummary> getTeam(String id) async {
    await _ensureHydrated();

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
      await _persistCache();
      return team;
    } catch (_) {
      final cachedTeam = _teamCache[id];
      if (cachedTeam != null) {
        return cachedTeam;
      }

      throw const AppFailure('팀 정보를 불러오지 못했습니다.');
    }
  }

  Future<TeamSummary?> findTeamByTag(String tag) async {
    await _ensureHydrated();

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

    return null;
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
    return TeamSummary(
      id: dto.id,
      name: dto.name,
      initials: dto.shortName,
      rank: dto.rank ?? 0,
      seasonRecord: '${dto.wins}-${dto.losses}',
      setRecord: _formatDifferential(dto.setDifferential),
      summary: _buildSummary(dto),
      recentForm: recentForm ?? const [],
      recentMatches: recentMatches ?? const [],
      color: _fallbackColor(dto.shortName),
      logoUrl: dto.logoUrl,
    );
  }

  LckMatchResult _mapMatch(TeamMatchDto dto, {required String teamId}) {
    final isHomeTeam = dto.homeTeam.id == teamId;
    final opponent = isHomeTeam ? dto.awayTeam : dto.homeTeam;
    final teamScore = isHomeTeam ? dto.score.home : dto.score.away;
    final opponentScore = isHomeTeam ? dto.score.away : dto.score.home;

    return LckMatchResult(
      id: dto.id,
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

  String _buildSummary(TeamSummaryDto dto) {
    final rank = dto.rank;
    if (rank != null && rank > 0) {
      return '현재 $rank위, 시즌 ${dto.wins}승 ${dto.losses}패를 기록 중입니다.';
    }
    return '${dto.name}의 시즌 전적과 최근 경기 흐름을 확인할 수 있습니다.';
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

  Future<void> _ensureHydrated() {
    return _hydrateFuture ??= _hydrateCache();
  }

  Future<void> _hydrateCache() async {
    try {
      final rawValue = await _localStorage.readString(_storageKey);
      if (rawValue == null || rawValue.isEmpty) {
        return;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return;
      }

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final team = _teamFromJson(item);
        _teamCache[team.id] = team;
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _persistCache() async {
    try {
      final serialized = jsonEncode(
        _teamCache.values.map(_teamToJson).toList(growable: false),
      );
      await _localStorage.writeString(_storageKey, serialized);
    } catch (_) {
      return;
    }
  }

  List<TeamSummary> _cachedTeams({String? keyword}) {
    final normalizedKeyword = keyword?.trim().toLowerCase() ?? '';
    return _teamCache.values.where((team) {
      if (normalizedKeyword.isEmpty) {
        return true;
      }
      return team.name.toLowerCase().contains(normalizedKeyword) ||
          team.initials.toLowerCase().contains(normalizedKeyword);
    }).toList()..sort((left, right) {
      final rankComparison = left.rank.compareTo(right.rank);
      if (rankComparison != 0) {
        return rankComparison;
      }
      return left.name.compareTo(right.name);
    });
  }

  Map<String, dynamic> _teamToJson(TeamSummary team) {
    return <String, dynamic>{
      'id': team.id,
      'name': team.name,
      'initials': team.initials,
      'rank': team.rank,
      'seasonRecord': team.seasonRecord,
      'setRecord': team.setRecord,
      'summary': team.summary,
      'recentForm': team.recentForm,
      'recentMatches': team.recentMatches
          .map(
            (match) => <String, dynamic>{
              'id': match.id,
              'opponent': match.opponent,
              'playedAt': match.playedAt.toIso8601String(),
              'outcome': match.outcome,
              'score': match.score,
              'note': match.note,
            },
          )
          .toList(growable: false),
      'color': team.color.toARGB32(),
      'logoUrl': team.logoUrl,
    };
  }

  TeamSummary _teamFromJson(Map<String, dynamic> json) {
    final recentForm =
        (json['recentForm'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList(growable: false);
    final recentMatches =
        (json['recentMatches'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => LckMatchResult(
                id: item['id']?.toString(),
                opponent: item['opponent']?.toString() ?? '',
                playedAt:
                    DateTime.tryParse(item['playedAt']?.toString() ?? '') ??
                    DateTime.fromMillisecondsSinceEpoch(0),
                outcome: item['outcome']?.toString() ?? '',
                score: item['score']?.toString() ?? '',
                note: item['note']?.toString() ?? '',
              ),
            )
            .toList(growable: false);

    return TeamSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      seasonRecord: json['seasonRecord']?.toString() ?? '0-0',
      setRecord: json['setRecord']?.toString() ?? '0',
      summary: json['summary']?.toString() ?? '',
      recentForm: recentForm,
      recentMatches: recentMatches,
      color: Color((json['color'] as num?)?.toInt() ?? 0xFFFFFFFF),
      logoUrl: json['logoUrl']?.toString(),
    );
  }
}
