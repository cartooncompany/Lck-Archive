class TeamSummaryDto {
  const TeamSummaryDto({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logoUrl,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.setWins,
    required this.setLosses,
    required this.setDifferential,
  });

  factory TeamSummaryDto.fromJson(Map<String, dynamic> json) {
    return TeamSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      logoUrl: json['logoUrl'] as String?,
      rank: json['rank'] as int?,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      setWins: json['setWins'] as int? ?? 0,
      setLosses: json['setLosses'] as int? ?? 0,
      setDifferential: json['setDifferential'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
  final int? rank;
  final int wins;
  final int losses;
  final int setWins;
  final int setLosses;
  final int setDifferential;
}
