import 'package:flutter/material.dart';

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    required this.position,
    required this.seasonMatches,
    required this.headline,
    required this.keyStats,
    required this.recentAppearances,
    required this.teamColor,
  });

  final String id;
  final String name;
  final String teamId;
  final String teamName;
  final String position;
  final int seasonMatches;
  final String headline;
  final Map<String, String> keyStats;
  final List<PlayerMatchAppearance> recentAppearances;
  final Color teamColor;
}

class PlayerMatchAppearance {
  const PlayerMatchAppearance({
    required this.playedAt,
    required this.opponent,
    required this.result,
    required this.performance,
  });

  final DateTime playedAt;
  final String opponent;
  final String result;
  final String performance;
}
