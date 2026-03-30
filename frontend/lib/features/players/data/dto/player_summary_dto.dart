class PlayerTeamDto {
  const PlayerTeamDto({
    required this.id,
    required this.shortName,
    required this.name,
    required this.logoUrl,
  });

  factory PlayerTeamDto.fromJson(Map<String, dynamic> json) {
    return PlayerTeamDto(
      id: json['id'] as String,
      shortName: json['shortName'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  final String id;
  final String shortName;
  final String name;
  final String? logoUrl;
}

class PlayerSummaryDto {
  const PlayerSummaryDto({
    required this.id,
    required this.name,
    required this.position,
    required this.profileImageUrl,
    required this.recentMatchCount,
    required this.team,
  });

  factory PlayerSummaryDto.fromJson(Map<String, dynamic> json) {
    return PlayerSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      recentMatchCount: json['recentMatchCount'] as int? ?? 0,
      team: json['team'] is Map<String, dynamic>
          ? PlayerTeamDto.fromJson(json['team'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String name;
  final String position;
  final String? profileImageUrl;
  final int recentMatchCount;
  final PlayerTeamDto? team;
}
