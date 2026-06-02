import 'player_summary_dto.dart';

class PlayerStatsDto {
  const PlayerStatsDto({
    required this.gamesPlayed,
    required this.totalKills,
    required this.totalDeaths,
    required this.totalAssists,
    required this.avgKills,
    required this.avgDeaths,
    required this.avgAssists,
    required this.avgKda,
  });

  factory PlayerStatsDto.fromJson(Map<String, dynamic> json) {
    return PlayerStatsDto(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      totalKills: json['totalKills'] as int? ?? 0,
      totalDeaths: json['totalDeaths'] as int? ?? 0,
      totalAssists: json['totalAssists'] as int? ?? 0,
      avgKills: (json['avgKills'] as num?)?.toDouble() ?? 0.0,
      avgDeaths: (json['avgDeaths'] as num?)?.toDouble() ?? 0.0,
      avgAssists: (json['avgAssists'] as num?)?.toDouble() ?? 0.0,
      avgKda: (json['avgKda'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final int gamesPlayed;
  final int totalKills;
  final int totalDeaths;
  final int totalAssists;
  final double avgKills;
  final double avgDeaths;
  final double avgAssists;
  final double avgKda;
}

class PlayerDetailDto extends PlayerSummaryDto {
  const PlayerDetailDto({
    required super.id,
    required super.name,
    required super.position,
    required super.profileImageUrl,
    required super.recentMatchCount,
    required super.team,
    required this.realName,
    required this.nationality,
    required this.birthDate,
    required this.stats,
  });

  factory PlayerDetailDto.fromJson(Map<String, dynamic> json) {
    return PlayerDetailDto(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      recentMatchCount: json['recentMatchCount'] as int? ?? 0,
      team: json['team'] is Map<String, dynamic>
          ? PlayerTeamDto.fromJson(json['team'] as Map<String, dynamic>)
          : null,
      realName: json['realName'] as String?,
      nationality: json['nationality'] as String?,
      birthDate: json['birthDate'] is String
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      stats: json['stats'] is Map<String, dynamic>
          ? PlayerStatsDto.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  final String? realName;
  final String? nationality;
  final DateTime? birthDate;
  final PlayerStatsDto? stats;
}
