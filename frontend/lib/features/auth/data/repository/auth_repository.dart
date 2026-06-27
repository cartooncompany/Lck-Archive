import 'package:frontend/core/error/app_failure.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:frontend/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/datasource/auth_session_store.dart';
import 'package:frontend/features/auth/data/models/auth_session.dart';
import 'package:frontend/features/auth/data/models/auth_user.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required AuthSessionStore sessionStore,
  }) : _remoteDataSource = remoteDataSource,
       _sessionStore = sessionStore;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionStore _sessionStore;

  @override
  Future<AuthSession?> restoreSession() async {
    final storedSession = await _sessionStore.read();
    if (storedSession == null) {
      return null;
    }

    try {
      final activeSession = await _sessionStore.ensureFresh(storedSession);
      final user = await _fetchProfile();
      final resolvedSession = activeSession.copyWith(user: user);
      await _sessionStore.persist(resolvedSession);
      return resolvedSession;
    } on AppFailure catch (error) {
      if (error.isUnauthorized) {
        await signOut();
        return null;
      }
      return storedSession;
    } catch (_) {
      return storedSession;
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = (await _remoteDataSource.login(
      email: email.trim(),
      password: password,
    )).toModel();
    await _sessionStore.persist(session);
    return session;
  }

  @override
  Future<AuthSession> signUp({
    required String nickname,
    required String email,
    required String password,
    required String favoriteTeamId,
  }) async {
    final session = (await _remoteDataSource.signUp(
      nickname: nickname.trim(),
      email: email.trim(),
      password: password,
      favoriteTeamId: favoriteTeamId,
    )).toModel();
    await _sessionStore.persist(session);
    return session;
  }

  @override
  Future<AuthUser> getMyProfile() async {
    final session = await _sessionStore.read();
    if (session == null) {
      throw const AppFailure('로그인이 필요합니다.', statusCode: 401);
    }

    // 토큰 주입/401 재시도는 AuthInterceptor가 처리하므로 단순 호출한다.
    final user = await _fetchProfile();
    final updatedSession = session.copyWith(user: user);
    await _sessionStore.persist(updatedSession);
    return user;
  }

  @override
  Future<void> deleteAccount() async {
    final session = await _sessionStore.read();
    if (session == null) {
      throw const AppFailure('로그인이 필요합니다.', statusCode: 401);
    }

    try {
      await _remoteDataSource.deleteMyAccount();
      await signOut();
    } on AppFailure catch (error) {
      if (error.statusCode == 404) {
        await signOut();
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _sessionStore.clear();
  }

  Future<AuthUser> _fetchProfile() async {
    return (await _remoteDataSource.getMyProfile()).toModel();
  }
}
