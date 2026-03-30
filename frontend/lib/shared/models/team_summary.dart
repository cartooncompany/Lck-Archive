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

  String get latestResult {
    if (recentMatches.isEmpty) {
      return '최근 경기 데이터 없음';
    }
    final match = recentMatches.first;
    return '${match.outcome} ${match.score} vs ${match.opponent}';
  }
}
