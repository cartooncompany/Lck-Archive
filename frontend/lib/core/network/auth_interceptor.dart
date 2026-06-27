import 'package:dio/dio.dart';

import 'package:frontend/features/auth/data/datasource/auth_session_store.dart';
import 'package:frontend/core/logging/app_logger.dart';

/// 모든 요청에 액세스 토큰을 자동 주입하고, 401 응답 시 토큰을 갱신해
/// 원요청을 한 번 재시도하는 Dio 인터셉터.
///
/// 토큰 주입과 401 재시도 로직을 한 곳에 모아, 각 데이터소스가 수동으로
/// `Authorization` 헤더를 붙이거나 갱신 재시도를 구현할 필요가 없게 한다.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required AuthSessionStore sessionStore, required Dio dio})
    : _sessionStore = sessionStore,
      _dio = dio;

  final AuthSessionStore _sessionStore;
  final Dio _dio;

  /// 토큰을 붙이지 않고, 401이 나도 갱신을 시도하지 않는 경로.
  /// (로그인/회원가입/토큰 재발급 자체는 인증 흐름의 진입점)
  static const _publicPaths = <String>{
    '/auth/login',
    '/auth/signup',
    '/auth/refresh',
  };

  /// 401로 인해 이미 한 번 재시도된 요청을 표시하는 플래그 키.
  static const _retriedKey = 'auth_interceptor.retried';

  bool _isPublic(RequestOptions options) {
    return _publicPaths.any((path) => options.path.endsWith(path));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublic(options)) {
      handler.next(options);
      return;
    }

    // 호출처가 명시적으로 헤더를 지정한 경우 존중한다.
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    final session = await _sessionStore.read();
    if (session == null) {
      handler.next(options);
      return;
    }

    try {
      final fresh = await _sessionStore.ensureFresh(session);
      options.headers['Authorization'] = 'Bearer ${fresh.accessToken}';
    } catch (_) {
      // 선제 갱신 실패 시 토큰 없이 진행한다. 서버가 401을 반환하면
      // onError에서 처리된다.
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = options.extra[_retriedKey] == true;

    if (!isUnauthorized || alreadyRetried || _isPublic(options)) {
      handler.next(err);
      return;
    }

    final session = await _sessionStore.read();
    if (session == null) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _sessionStore.refresh(session);
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';

      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } catch (error) {
      AppLogger.warning(
        'Token refresh failed during 401 retry. Propagating original error.',
        tag: 'AUTH',
        data: {'path': options.path},
      );
      handler.next(err);
    }
  }
}
