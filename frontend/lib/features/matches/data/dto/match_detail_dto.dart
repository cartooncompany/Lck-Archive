import '../../../teams/data/dto/team_match_dto.dart';

class MatchParticipantDto {
  const MatchParticipantDto({
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.isStarter,
    required this.team,
  });

  factory MatchParticipantDto.fromJson(Map<String, dynamic> json) {
    return MatchParticipantDto(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      position: json['position'] as String? ?? '',
      isStarter: json['isStarter'] as bool? ?? false,
      team: TeamMatchTeamDto.fromJson(json['team'] as Map<String, dynamic>),
    );
  }

  final String playerId;
  final String playerName;
  final String position;
  final bool isStarter;
  final TeamMatchTeamDto team;
}

class MatchGamePlayerStatDto {
  const MatchGamePlayerStatDto({
    required this.playerId,
    required this.playerName,
    required this.team,
    required this.position,
    required this.championName,
    required this.kills,
    required this.deaths,
    required this.assists,
    required this.totalGold,
    required this.damageDealt,
    required this.damageTaken,
    required this.visionScore,
    required this.kdaRatio,
    required this.killParticipation,
  });

  factory MatchGamePlayerStatDto.fromJson(Map<String, dynamic> json) {
    return MatchGamePlayerStatDto(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      team: TeamMatchTeamDto.fromJson(json['team'] as Map<String, dynamic>),
      position: json['position'] as String?,
      championName: json['championName'] as String?,
      kills: (json['kills'] as num?)?.toInt(),
      deaths: (json['deaths'] as num?)?.toInt(),
      assists: (json['assists'] as num?)?.toInt(),
      totalGold: (json['totalGold'] as num?)?.toInt(),
      damageDealt: (json['damageDealt'] as num?)?.toInt(),
      damageTaken: (json['damageTaken'] as num?)?.toInt(),
      visionScore: (json['visionScore'] as num?)?.toDouble(),
      kdaRatio: (json['kdaRatio'] as num?)?.toDouble(),
      killParticipation: (json['killParticipation'] as num?)?.toDouble(),
    );
  }

  final String playerId;
  final String playerName;
  final TeamMatchTeamDto team;
  final String? position;
  final String? championName;
  final int? kills;
  final int? deaths;
  final int? assists;
  final int? totalGold;
  final int? damageDealt;
  final int? damageTaken;
  final double? visionScore;
  final double? kdaRatio;
  final double? killParticipation;
}

class MatchDraftActionDto {
  const MatchDraftActionDto({
    required this.type,
    required this.sequenceNumber,
    required this.drafterId,
    required this.drafterType,
    required this.draftableType,
    required this.draftableName,
  });

  factory MatchDraftActionDto.fromJson(Map<String, dynamic> json) {
    return MatchDraftActionDto(
      type: json['type'] as String? ?? '',
      sequenceNumber: json['sequenceNumber'] as String? ?? '',
      drafterId: json['drafterId'] as String?,
      drafterType: json['drafterType'] as String?,
      draftableType: json['draftableType'] as String?,
      draftableName: json['draftableName'] as String?,
    );
  }

  final String type;
  final String sequenceNumber;
  final String? drafterId;
  final String? drafterType;
  final String? draftableType;
  final String? draftableName;
}

class MatchGameDto {
  const MatchGameDto({
    required this.sequenceNumber,
    required this.mapName,
    required this.duration,
    required this.startedAt,
    required this.winner,
    required this.playerStats,
    required this.draftActions,
  });

  factory MatchGameDto.fromJson(Map<String, dynamic> json) {
    return MatchGameDto(
      sequenceNumber: json['sequenceNumber'] as int? ?? 0,
      mapName: json['mapName'] as String?,
      duration: json['duration'] as String?,
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      winner: json['winner'] is Map<String, dynamic>
          ? TeamMatchTeamDto.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
      playerStats: (json['playerStats'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(MatchGamePlayerStatDto.fromJson)
          .toList(growable: false),
      draftActions:
          (json['draftActions'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(MatchDraftActionDto.fromJson)
              .toList(growable: false),
    );
  }

  final int sequenceNumber;
  final String? mapName;
  final String? duration;
  final DateTime? startedAt;
  final TeamMatchTeamDto? winner;
  final List<MatchGamePlayerStatDto> playerStats;
  final List<MatchDraftActionDto> draftActions;
}

class MatchDetailDto extends TeamMatchDto {
  const MatchDetailDto({
    required super.id,
    required super.scheduledAt,
    required super.seasonYear,
    required super.split,
    required super.stage,
    required super.status,
    required super.homeTeam,
    required super.awayTeam,
    required super.score,
    required super.winner,
    required this.matchNumber,
    required this.vodUrl,
    required this.participants,
    required this.games,
  });

  factory MatchDetailDto.fromJson(Map<String, dynamic> json) {
    return MatchDetailDto(
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
      matchNumber: json['matchNumber'] as String?,
      vodUrl: json['vodUrl'] as String?,
      participants:
          (json['participants'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(MatchParticipantDto.fromJson)
              .toList(growable: false),
      games: (json['games'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(MatchGameDto.fromJson)
          .toList(growable: false),
    );
  }

  final String? matchNumber;
  final String? vodUrl;
  final List<MatchParticipantDto> participants;
  final List<MatchGameDto> games;
}
