class TeamMatchTeamDto {
  const TeamMatchTeamDto({
    required this.id,
    required this.shortName,
    required this.name,
    required this.logoUrl,
  });

  factory TeamMatchTeamDto.fromJson(Map<String, dynamic> json) {
    return TeamMatchTeamDto(
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

class TeamMatchScoreDto {
  const TeamMatchScoreDto({required this.home, required this.away});

  factory TeamMatchScoreDto.fromJson(Map<String, dynamic> json) {
    return TeamMatchScoreDto(
      home: json['home'] as int? ?? 0,
      away: json['away'] as int? ?? 0,
    );
  }

  final int home;
  final int away;
}

class TeamMatchDto {
  const TeamMatchDto({
    required this.id,
    required this.scheduledAt,
    required this.seasonYear,
    required this.split,
    required this.stage,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required this.winner,
  });

  factory TeamMatchDto.fromJson(Map<String, dynamic> json) {
    return TeamMatchDto(
      id: json['id'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      seasonYear: json['seasonYear'] as int? ?? 0,
      split: json['split'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      status: json['status'] as String? ?? 'SCHEDULED',
      homeTeam: TeamMatchTeamDto.fromJson(
        json['homeTeam'] as Map<String, dynamic>,
      ),
      awayTeam: TeamMatchTeamDto.fromJson(
        json['awayTeam'] as Map<String, dynamic>,
      ),
      score: TeamMatchScoreDto.fromJson(json['score'] as Map<String, dynamic>),
      winner: json['winner'] is Map<String, dynamic>
          ? TeamMatchTeamDto.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final DateTime scheduledAt;
  final int seasonYear;
  final String split;
  final String stage;
  final String status;
  final TeamMatchTeamDto homeTeam;
  final TeamMatchTeamDto awayTeam;
  final TeamMatchScoreDto score;
  final TeamMatchTeamDto? winner;
}
