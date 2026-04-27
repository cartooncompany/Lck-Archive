import '../../../../core/network/api_client.dart';
import '../dto/access_token_dto.dart';
import '../dto/auth_session_dto.dart';
import '../dto/auth_user_dto.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) {
    return _apiClient.post(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
      decoder: (data) => AuthSessionDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthSessionDto> signUp({
    required String nickname,
    required String email,
    required String password,
    required String favoriteTeamId,
  }) {
    return _apiClient.post(
      '/auth/signup',
      data: <String, dynamic>{
        'nickname': nickname,
        'email': email,
        'password': password,
        'favoriteTeamId': favoriteTeamId,
      },
      decoder: (data) => AuthSessionDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AccessTokenDto> refreshAccessToken(String refreshToken) {
    return _apiClient.post(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
      decoder: (data) => AccessTokenDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthUserDto> getMyProfile(String accessToken) {
    return _apiClient.get(
      '/users/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      decoder: (data) => AuthUserDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteMyAccount(String accessToken) {
    return _apiClient.deleteVoid(
      '/users/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }
}
