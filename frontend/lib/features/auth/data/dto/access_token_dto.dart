class AccessTokenDto {
  const AccessTokenDto({
    required this.accessToken,
    required this.accessTokenExpiresAt,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;

  factory AccessTokenDto.fromJson(Map<String, dynamic> json) {
    return AccessTokenDto(
      accessToken: json['accessToken']?.toString() ?? '',
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt']?.toString() ?? '',
      ).toUtc(),
    );
  }
}
