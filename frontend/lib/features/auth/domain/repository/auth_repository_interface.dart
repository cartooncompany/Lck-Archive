import '../../data/models/auth_session.dart';
import '../../data/models/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthSession?> restoreSession();
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> signUp({
    required String nickname,
    required String email,
    required String password,
    required String favoriteTeamId,
  });
  Future<AuthUser> getMyProfile();
  Future<void> deleteAccount();
  Future<void> signOut();
}
