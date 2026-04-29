import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/shared/models/lck_match_result.dart';
import 'package:frontend/shared/models/player_profile.dart';
import 'package:frontend/shared/models/team_summary.dart';

final sampleFavoriteTeam = TeamSummary(
  id: 't1',
  name: 'T1',
  initials: 'T1',
  rank: 1,
  seasonRecord: '14-3',
  setRecord: '+18',
  summary: '라인전 주도권과 한타 집중력이 안정적인 상위권 팀입니다.',
  recentForm: <String>['W', 'W', 'W', 'L', 'W'],
  recentMatches: <LckMatchResult>[
    LckMatchResult(
      opponent: 'Gen.G',
      playedAt: DateTime(2026, 4, 20),
      outcome: 'W',
      score: '2:1',
      note: '후반 오브젝트 교전 우위',
    ),
  ],
  color: Color(0xFFE74C3C),
);

final sampleHleTeam = TeamSummary(
  id: 'hle',
  name: 'Hanwha Life Esports',
  initials: 'HLE',
  rank: 3,
  seasonRecord: '11-6',
  setRecord: '+9',
  summary: '상체 교전과 캐리 라인 파괴력이 강한 팀입니다.',
  recentForm: <String>['W', 'L', 'W', 'W', 'L'],
  recentMatches: <LckMatchResult>[
    LckMatchResult(
      opponent: 'DRX',
      playedAt: DateTime(2026, 4, 18),
      outcome: 'W',
      score: '2:0',
      note: '초반 전령 구간 주도',
    ),
  ],
  color: Color(0xFFFF7A00),
);

final sampleKtTeam = TeamSummary(
  id: 'kt',
  name: 'KT Rolster',
  initials: 'KT',
  rank: 5,
  seasonRecord: '8-9',
  setRecord: '-2',
  summary: '중반 운영 변수가 큰 팀입니다.',
  recentForm: <String>['L', 'W', 'L', 'W', 'L'],
  recentMatches: <LckMatchResult>[
    LckMatchResult(
      opponent: 'T1',
      playedAt: DateTime(2026, 4, 17),
      outcome: 'L',
      score: '0:2',
      note: '라인 스왑 대응 열세',
    ),
  ],
  color: Color(0xFF111111),
);

const sampleFaker = PlayerProfile(
  id: 'faker',
  name: 'Faker',
  teamId: 't1',
  teamName: 'T1',
  position: 'MID',
  seasonMatches: 17,
  headline: '중후반 한타 설계와 오브젝트 전투 판단이 뛰어납니다.',
  keyStats: <String, String>{'KDA': '4.7'},
  recentAppearances: <PlayerMatchAppearance>[],
  teamColor: Color(0xFFE74C3C),
);

const sampleDeft = PlayerProfile(
  id: 'deft',
  name: 'Deft',
  teamId: 'kt',
  teamName: 'KT Rolster',
  position: 'ADC',
  seasonMatches: 16,
  headline: '후반 교전에서 안정적인 딜링을 기대할 수 있습니다.',
  keyStats: <String, String>{'DPM': '598'},
  recentAppearances: <PlayerMatchAppearance>[],
  teamColor: Color(0xFF111111),
);

const sampleZeka = PlayerProfile(
  id: 'zeka',
  name: 'Zeka',
  teamId: 'hle',
  teamName: 'Hanwha Life Esports',
  position: 'MID',
  seasonMatches: 17,
  headline: '교전 개시와 메이킹 비중이 높은 미드 라이너입니다.',
  keyStats: <String, String>{},
  recentAppearances: <PlayerMatchAppearance>[],
  teamColor: Color(0xFFFF7A00),
);

const sampleViper = PlayerProfile(
  id: 'viper',
  name: 'Viper',
  teamId: 'hle',
  teamName: 'Hanwha Life Esports',
  position: 'ADC',
  seasonMatches: 17,
  headline: '라인전과 후반 캐리 기대치가 모두 높은 원딜입니다.',
  keyStats: <String, String>{},
  recentAppearances: <PlayerMatchAppearance>[],
  teamColor: Color(0xFFFF7A00),
);

const sampleDelight = PlayerProfile(
  id: 'delight',
  name: 'Delight',
  teamId: 'hle',
  teamName: 'Hanwha Life Esports',
  position: 'SUP',
  seasonMatches: 17,
  headline: '시야 장악과 교전 개시 기여도가 높은 서포터입니다.',
  keyStats: <String, String>{},
  recentAppearances: <PlayerMatchAppearance>[],
  teamColor: Color(0xFFFF7A00),
);

class SampleLckApiClient implements ApiClient {
  static const List<Map<String, dynamic>> _teams = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 't1',
      'name': 'T1',
      'shortName': 'T1',
      'logoUrl': null,
      'rank': 1,
      'wins': 14,
      'losses': 3,
      'setWins': 29,
      'setLosses': 11,
      'setDifferential': 18,
    },
    <String, dynamic>{
      'id': 'hle',
      'name': 'Hanwha Life Esports',
      'shortName': 'HLE',
      'logoUrl': null,
      'rank': 3,
      'wins': 11,
      'losses': 6,
      'setWins': 24,
      'setLosses': 15,
      'setDifferential': 9,
    },
    <String, dynamic>{
      'id': 'kt',
      'name': 'KT Rolster',
      'shortName': 'KT',
      'logoUrl': null,
      'rank': 5,
      'wins': 8,
      'losses': 9,
      'setWins': 18,
      'setLosses': 20,
      'setDifferential': -2,
    },
  ];

  static const List<Map<String, dynamic>> _players = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'faker',
      'name': 'Faker',
      'position': 'MID',
      'profileImageUrl': null,
      'recentMatchCount': 17,
      'team': <String, dynamic>{
        'id': 't1',
        'shortName': 'T1',
        'name': 'T1',
        'logoUrl': null,
      },
    },
    <String, dynamic>{
      'id': 'deft',
      'name': 'Deft',
      'position': 'ADC',
      'profileImageUrl': null,
      'recentMatchCount': 16,
      'team': <String, dynamic>{
        'id': 'kt',
        'shortName': 'KT',
        'name': 'KT Rolster',
        'logoUrl': null,
      },
    },
    <String, dynamic>{
      'id': 'zeka',
      'name': 'Zeka',
      'position': 'MID',
      'profileImageUrl': null,
      'recentMatchCount': 17,
      'team': <String, dynamic>{
        'id': 'hle',
        'shortName': 'HLE',
        'name': 'Hanwha Life Esports',
        'logoUrl': null,
      },
    },
    <String, dynamic>{
      'id': 'viper',
      'name': 'Viper',
      'position': 'ADC',
      'profileImageUrl': null,
      'recentMatchCount': 17,
      'team': <String, dynamic>{
        'id': 'hle',
        'shortName': 'HLE',
        'name': 'Hanwha Life Esports',
        'logoUrl': null,
      },
    },
    <String, dynamic>{
      'id': 'delight',
      'name': 'Delight',
      'position': 'SUPPORT',
      'profileImageUrl': null,
      'recentMatchCount': 17,
      'team': <String, dynamic>{
        'id': 'hle',
        'shortName': 'HLE',
        'name': 'Hanwha Life Esports',
        'logoUrl': null,
      },
    },
  ];

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    switch (path) {
      case '/teams':
        return decoder(
          _pagedResponse(
            _filterTeams(queryParameters),
            page: _readPage(queryParameters),
            limit: _readLimit(queryParameters),
          ),
        );
      case '/players':
        return decoder(
          _pagedResponse(
            _filterPlayers(queryParameters),
            page: _readPage(queryParameters),
            limit: _readLimit(queryParameters),
          ),
        );
    }

    throw UnimplementedError('Unhandled GET path: $path');
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    throw UnimplementedError('Unhandled POST path: $path');
  }

  @override
  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError('Unhandled POST VOID path: $path');
  }

  @override
  Future<void> deleteVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError('Unhandled DELETE path: $path');
  }

  List<Map<String, dynamic>> _filterTeams(
    Map<String, dynamic>? queryParameters,
  ) {
    final keyword =
        queryParameters?['keyword']?.toString().trim().toLowerCase() ?? '';
    if (keyword.isEmpty) {
      return _teams;
    }

    return _teams.where((team) {
      final name = team['name'].toString().toLowerCase();
      final shortName = team['shortName'].toString().toLowerCase();
      return name.contains(keyword) || shortName.contains(keyword);
    }).toList();
  }

  List<Map<String, dynamic>> _filterPlayers(
    Map<String, dynamic>? queryParameters,
  ) {
    final keyword =
        queryParameters?['keyword']?.toString().trim().toLowerCase() ?? '';
    final teamId = queryParameters?['teamId']?.toString();
    final position = queryParameters?['position']
        ?.toString()
        .trim()
        .toUpperCase();

    return _players.where((player) {
      final playerName = player['name'].toString().toLowerCase();
      final playerTeam = player['team'] as Map<String, dynamic>?;
      final playerPosition = player['position'].toString().toUpperCase();
      final matchesKeyword = keyword.isEmpty || playerName.contains(keyword);
      final matchesTeam = teamId == null || playerTeam?['id'] == teamId;
      final matchesPosition =
          position == null || position.isEmpty || playerPosition == position;
      return matchesKeyword && matchesTeam && matchesPosition;
    }).toList();
  }

  int _readPage(Map<String, dynamic>? queryParameters) {
    return (queryParameters?['page'] as int?) ?? 1;
  }

  int _readLimit(Map<String, dynamic>? queryParameters) {
    return (queryParameters?['limit'] as int?) ?? 100;
  }

  Map<String, dynamic> _pagedResponse(
    List<Map<String, dynamic>> items, {
    required int page,
    required int limit,
  }) {
    final start = (page - 1) * limit;
    final end = start + limit > items.length ? items.length : start + limit;
    final pagedItems = start >= items.length
        ? const <Map<String, dynamic>>[]
        : items.sublist(start, end);
    final totalPages = items.isEmpty ? 0 : (items.length / limit).ceil();

    return <String, dynamic>{
      'items': pagedItems,
      'meta': <String, dynamic>{
        'page': page,
        'limit': limit,
        'total': items.length,
        'totalPages': totalPages,
      },
    };
  }
}

class MemoryLocalStorage implements LocalStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> readString(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}
