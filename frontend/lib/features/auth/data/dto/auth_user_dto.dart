import '../models/auth_user.dart';

class AuthUserDto {
  const AuthUserDto({required this.nickname, required this.email});

  final String nickname;
  final String email;

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      nickname: json['nickname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  AuthUser toModel() {
    return AuthUser(nickname: nickname, email: email);
  }
}
