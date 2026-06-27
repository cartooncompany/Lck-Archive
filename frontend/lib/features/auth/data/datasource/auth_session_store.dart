import 'dart:async';
import 'dart:convert';

import 'package:frontend/core/error/app_failure.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/features/auth/data/models/auth_session.dart';
import 'auth_remote_data_source.dart';

/// 인증 세션의 저장/조회/갱신을 단일 지점에서 관리한다.
///
/// `AuthRepository`(고수준 인증 흐름)와 `AuthInterceptor`(요청 단위 토큰
/// 주입/갱신)가 동일한 세션 상태를 공유하기 위해 분리한 컴포넌트다.
/// 동시에 여러 요청이 401을 받아도 토큰 갱신은 한 번만 수행되도록 보장한다.
class AuthSessionStore {
  AuthSessionStore({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  static const String _storageKey = 'auth_repository.session.v1';
  static const Duration _refreshLeeway = Duration(minutes: 1);

  /// 진행 중인 토큰 갱신이 있으면 그 Future를 공유한다. (단일 갱신 보장)
  Future<AuthSession>? _inflightRefresh;

  Future<AuthSession?> read() async {
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

  Future<void> persist(AuthSession session) async {
    await _localStorage.writeString(_storageKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    await _localStorage.delete(_storageKey);
  }

  /// 액세스 토큰이 곧 만료되면 선제적으로 갱신해 유효한 세션을 반환한다.
  Future<AuthSession> ensureFresh(AuthSession session) {
    final refreshThreshold = DateTime.now().toUtc().add(_refreshLeeway);
    if (session.accessTokenExpiresAt.isAfter(refreshThreshold)) {
      return Future<AuthSession>.value(session);
    }
    return refresh(session);
  }

  /// 리프레시 토큰으로 액세스 토큰을 재발급한다.
  ///
  /// 동시에 호출되어도 실제 네트워크 갱신은 한 번만 수행하고 결과를 공유한다.
  Future<AuthSession> refresh(AuthSession session) {
    final inflight = _inflightRefresh;
    if (inflight != null) {
      return inflight;
    }

    final future = _performRefresh(session).whenComplete(() {
      _inflightRefresh = null;
    });
    _inflightRefresh = future;
    return future;
  }

  Future<AuthSession> _performRefresh(AuthSession session) async {
    final now = DateTime.now().toUtc();
    if (!session.refreshTokenExpiresAt.isAfter(now)) {
      await clear();
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
      await persist(refreshedSession);
      return refreshedSession;
    } on AppFailure catch (error) {
      if (error.isUnauthorized) {
        await clear();
        throw const AppFailure('세션이 만료되었습니다. 다시 로그인해 주세요.', statusCode: 401);
      }
      rethrow;
    }
  }
}
