class AuthUser {
  const AuthUser({required this.nickname, required this.email});

  final String nickname;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      nickname: json['nickname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'nickname': nickname, 'email': email};
  }
}
