class LckScheduledTeam {
  const LckScheduledTeam({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
}

class LckScheduledMatch {
  const LckScheduledMatch({
    required this.id,
    required this.scheduledAt,
    required this.split,
    required this.stage,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
  });

  final String id;
  final DateTime scheduledAt;
  final String split;
  final String stage;
  final String status;
  final LckScheduledTeam homeTeam;
  final LckScheduledTeam awayTeam;

  String get note {
    return [
      split.trim(),
      stage.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
  }
}
