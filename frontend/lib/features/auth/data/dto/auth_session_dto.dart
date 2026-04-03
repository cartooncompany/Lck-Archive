import '../models/auth_session.dart';
import 'auth_user_dto.dart';

class AuthSessionDto {
  const AuthSessionDto({
    required this.user,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  final AuthUserDto user;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      user: AuthUserDto.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken']?.toString() ?? '',
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt']?.toString() ?? '',
      ).toUtc(),
      refreshToken: json['refreshToken']?.toString() ?? '',
      refreshTokenExpiresAt: DateTime.parse(
        json['refreshTokenExpiresAt']?.toString() ?? '',
      ).toUtc(),
    );
  }

  AuthSession toModel() {
    return AuthSession(
      user: user.toModel(),
      accessToken: accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );
  }
}
