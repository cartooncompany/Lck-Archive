import 'dart:convert';

import '../../../../core/error/app_failure.dart';
import '../../../../core/storage/local_storage.dart';
import '../datasource/auth_remote_data_source.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  static const String _storageKey = 'auth_repository.session.v1';
  static const Duration _refreshLeeway = Duration(minutes: 1);

  Future<AuthSession?> restoreSession() async {
    final storedSession = await _readSession();
    if (storedSession == null) {
      return null;
    }

    try {
      final activeSession = await _ensureFreshSession(storedSession);
      final user = await _fetchProfile(activeSession);
      final resolvedSession = activeSession.copyWith(user: user);
      await _persistSession(resolvedSession);
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

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = (await _remoteDataSource.login(
      email: email.trim(),
      password: password,
    )).toModel();
    await _persistSession(session);
    return session;
  }

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
    await _persistSession(session);
    return session;
  }

  Future<AuthUser> getMyProfile() async {
    final session = await _readSession();
    if (session == null) {
      throw const AppFailure('로그인이 필요합니다.', statusCode: 401);
    }

    try {
      final activeSession = await _ensureFreshSession(session);
      final user = await _fetchProfile(activeSession);
      final updatedSession = activeSession.copyWith(user: user);
      await _persistSession(updatedSession);
      return user;
    } on AppFailure catch (error) {
      if (error.isUnauthorized) {
        final refreshedSession = await _refreshSession(session);
        final user = await _fetchProfile(refreshedSession);
        final updatedSession = refreshedSession.copyWith(user: user);
        await _persistSession(updatedSession);
        return user;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _localStorage.delete(_storageKey);
  }

  Future<AuthSession?> _readSession() async {
    try {
      final rawValue = await _localStorage.readString(_storageKey);
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return AuthSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    await _localStorage.writeString(_storageKey, jsonEncode(session.toJson()));
  }

  Future<AuthSession> _ensureFreshSession(AuthSession session) {
    final refreshThreshold = DateTime.now().toUtc().add(_refreshLeeway);
    if (session.accessTokenExpiresAt.isAfter(refreshThreshold)) {
      return Future<AuthSession>.value(session);
    }

    return _refreshSession(session);
  }

  Future<AuthSession> _refreshSession(AuthSession session) async {
    final now = DateTime.now().toUtc();
    if (!session.refreshTokenExpiresAt.isAfter(now)) {
      await signOut();
      throw const AppFailure('세션이 만료되었습니다. 다시 로그인해 주세요.', statusCode: 401);
    }

    try {
      final refreshedToken = await _remoteDataSource.refreshAccessToken(
        session.refreshToken,
      );
      final refreshedSession = session.copyWith(
        accessToken: refreshedToken.accessToken,
        accessTokenExpiresAt: refreshedToken.accessTokenExpiresAt,
      );
      await _persistSession(refreshedSession);
      return refreshedSession;
    } on AppFailure catch (error) {
      if (error.isUnauthorized) {
        await signOut();
        throw const AppFailure('세션이 만료되었습니다. 다시 로그인해 주세요.', statusCode: 401);
      }
      rethrow;
    }
  }

  Future<AuthUser> _fetchProfile(AuthSession session) async {
    return (await _remoteDataSource.getMyProfile(
      session.accessToken,
    )).toModel();
  }
}
