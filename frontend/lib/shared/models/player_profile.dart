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
    this.profileImageUrl,
    this.realName,
    this.nationality,
    this.birthDate,
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
