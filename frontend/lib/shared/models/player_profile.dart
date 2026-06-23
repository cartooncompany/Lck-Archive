import 'package:flutter/material.dart';

class PlayerStats {
  const PlayerStats({
    required this.gamesPlayed,
    required this.totalKills,
    required this.totalDeaths,
    required this.totalAssists,
    required this.avgKills,
    required this.avgDeaths,
    required this.avgAssists,
    required this.avgKda,
  });

  final int gamesPlayed;
  final int totalKills;
  final int totalDeaths;
  final int totalAssists;
  final double avgKills;
  final double avgDeaths;
  final double avgAssists;
  final double avgKda;
}

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
    this.profileImageUrl,
    this.realName,
    this.nationality,
    this.birthDate,
    this.stats,
    this.aiSummary,
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
  final String? profileImageUrl;
  final String? realName;
  final String? nationality;
  final DateTime? birthDate;
  final PlayerStats? stats;
  final String? aiSummary;

  PlayerProfile copyWith({
    String? id,
    String? name,
    String? teamId,
    String? teamName,
    String? position,
    int? seasonMatches,
    String? headline,
    Map<String, String>? keyStats,
    List<PlayerMatchAppearance>? recentAppearances,
    Color? teamColor,
    String? profileImageUrl,
    String? realName,
    String? nationality,
    DateTime? birthDate,
    PlayerStats? stats,
    String? aiSummary,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      position: position ?? this.position,
      seasonMatches: seasonMatches ?? this.seasonMatches,
      headline: headline ?? this.headline,
      keyStats: keyStats ?? this.keyStats,
      recentAppearances: recentAppearances ?? this.recentAppearances,
      teamColor: teamColor ?? this.teamColor,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      realName: realName ?? this.realName,
      nationality: nationality ?? this.nationality,
      birthDate: birthDate ?? this.birthDate,
      stats: stats ?? this.stats,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }
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
