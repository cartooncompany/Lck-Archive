import 'player_summary_dto.dart';

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
    );
  }

  final String? realName;
  final String? nationality;
  final DateTime? birthDate;
}
