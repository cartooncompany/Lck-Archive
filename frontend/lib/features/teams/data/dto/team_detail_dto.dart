import 'team_summary_dto.dart';

class TeamDetailDto extends TeamSummaryDto {
  const TeamDetailDto({
    required super.id,
    required super.name,
    required super.shortName,
    required super.logoUrl,
    required super.rank,
    required super.wins,
    required super.losses,
    required super.setWins,
    required super.setLosses,
    required super.setDifferential,
    required this.recentForm,
  });

  factory TeamDetailDto.fromJson(Map<String, dynamic> json) {
    return TeamDetailDto(
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
      recentForm: (json['recentForm'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }

  final List<String> recentForm;
}
