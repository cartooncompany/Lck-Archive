import 'lck_scheduled_match.dart';

class LckMatchScore {
  const LckMatchScore({required this.home, required this.away});

  final int home;
  final int away;
}

class LckMatchDetail {
  const LckMatchDetail({
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
    required this.matchNumber,
    required this.vodUrl,
    required this.participants,
    required this.games,
  });

  final String id;
  final DateTime scheduledAt;
  final int seasonYear;
  final String split;
  final String stage;
  final String status;
  final LckScheduledTeam homeTeam;
  final LckScheduledTeam awayTeam;
  final LckMatchScore score;
  final LckScheduledTeam? winner;
  final String? matchNumber;
  final String? vodUrl;
  final List<LckMatchParticipant> participants;
  final List<LckMatchGame> games;

  String get note {
    return [
      if (seasonYear > 0) seasonYear.toString(),
      split.trim(),
      stage.trim(),
      if (matchNumber?.trim().isNotEmpty == true) matchNumber!.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
  }
}

class LckMatchParticipant {
  const LckMatchParticipant({
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.isStarter,
    required this.team,
  });

  final String playerId;
  final String playerName;
  final String position;
  final bool isStarter;
  final LckScheduledTeam team;
}

class LckMatchGame {
  const LckMatchGame({
    required this.sequenceNumber,
    required this.mapName,
    required this.duration,
    required this.startedAt,
    required this.winner,
    required this.playerStats,
    required this.draftActions,
  });

  final int sequenceNumber;
  final String? mapName;
  final String? duration;
  final DateTime? startedAt;
  final LckScheduledTeam? winner;
  final List<LckMatchGamePlayerStat> playerStats;
  final List<LckMatchDraftAction> draftActions;
}

class LckMatchGamePlayerStat {
  const LckMatchGamePlayerStat({
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

  final String playerId;
  final String playerName;
  final LckScheduledTeam team;
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

  String get kdaText {
    final killText = kills?.toString() ?? '-';
    final deathText = deaths?.toString() ?? '-';
    final assistText = assists?.toString() ?? '-';
    return '$killText / $deathText / $assistText';
  }
}

class LckMatchDraftAction {
  const LckMatchDraftAction({
    required this.type,
    required this.sequenceNumber,
    required this.drafterId,
    required this.drafterType,
    required this.draftableType,
    required this.draftableName,
  });

  final String type;
  final String sequenceNumber;
  final String? drafterId;
  final String? drafterType;
  final String? draftableType;
  final String? draftableName;
}
