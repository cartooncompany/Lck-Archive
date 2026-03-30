import 'package:flutter/material.dart';

import 'lck_match_result.dart';

class TeamSummary {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.initials,
    required this.rank,
    required this.seasonRecord,
    required this.setRecord,
    required this.summary,
    required this.recentForm,
    required this.recentMatches,
    required this.color,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String initials;
  final int rank;
  final String seasonRecord;
  final String setRecord;
  final String summary;
  final List<String> recentForm;
  final List<LckMatchResult> recentMatches;
  final Color color;
  final String? logoUrl;

  TeamSummary copyWith({
    String? id,
    String? name,
    String? initials,
    int? rank,
    String? seasonRecord,
    String? setRecord,
    String? summary,
    List<String>? recentForm,
    List<LckMatchResult>? recentMatches,
    Color? color,
    String? logoUrl,
  }) {
    return TeamSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      rank: rank ?? this.rank,
      seasonRecord: seasonRecord ?? this.seasonRecord,
      setRecord: setRecord ?? this.setRecord,
      summary: summary ?? this.summary,
      recentForm: recentForm ?? this.recentForm,
      recentMatches: recentMatches ?? this.recentMatches,
      color: color ?? this.color,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  String get rankLabel => rank > 0 ? '$rank위' : '순위 미정';

  String get latestResult {
    if (recentMatches.isEmpty) {
      return '최근 경기 데이터 없음';
    }
    final match = recentMatches.first;
    return '${match.outcome} ${match.score} vs ${match.opponent}';
  }
}
