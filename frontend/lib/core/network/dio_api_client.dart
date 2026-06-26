import 'package:dio/dio.dart';

import '../error/app_failure.dart';
import '../logging/app_logger.dart';
import 'api_client.dart';

class DioApiClient implements ApiClient {
  DioApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          responseType: ResponseType.json,
        ),
      ) {
    _installLoggingInterceptor();
  }

  final Dio _dio;
  static const String _requestStartedAtKey = 'requestStartedAt';

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return decoder(response.data);
    } on DioException catch (error) {
      throw AppFailure(
        _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to process GET response.',
        tag: 'HTTP',
        error: error,
        stackTrace: stackTrace,
        data: {'path': path},
      );
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return decoder(response.data);
    } on DioException catch (error) {
      throw AppFailure(
        _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to process POST response.',
        tag: 'HTTP',
        error: error,
        stackTrace: stackTrace,
        data: {'path': path},
      );
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (error) {
      throw AppFailure(
        _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to process POST response.',
        tag: 'HTTP',
        error: error,
        stackTrace: stackTrace,
        data: {'path': path},
      );
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> deleteVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (error) {
      throw AppFailure(
        _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to process DELETE response.',
        tag: 'HTTP',
        error: error,
        stackTrace: stackTrace,
        data: {'path': path},
      );
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
  }

  void _installLoggingInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra[_requestStartedAtKey] = DateTime.now();
          AppLogger.info(
            '--> ${options.method.toUpperCase()} ${options.uri}',
            tag: 'HTTP',
            data: {
              if (options.queryParameters.isNotEmpty)
                'query': options.queryParameters,
              if (options.data != null)
                'body': _sanitizeBody(options.data),
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
            '<-- ${response.statusCode ?? '-'} '
            '${response.requestOptions.method.toUpperCase()} '
            '${response.requestOptions.uri} '
            '(${_elapsedMs(response.requestOptions)}ms)',
            tag: 'HTTP',
            data: response.data,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            '<-- ${error.response?.statusCode ?? 'ERR'} '
            '${error.requestOptions.method.toUpperCase()} '
            '${error.requestOptions.uri} '
            '(${_elapsedMs(error.requestOptions)}ms)',
            tag: 'HTTP',
            error: error,
            stackTrace: error.stackTrace,
            data: {
              'message': error.message,
              if (error.response?.data != null)
                'response': error.response?.data,
            },
          );
          handler.next(error);
        },
      ),
    );
  }

  int _elapsedMs(RequestOptions options) {
    final startedAt = options.extra[_requestStartedAtKey];
    if (startedAt is! DateTime) {
      return 0;
    }

    return DateTime.now().difference(startedAt).inMilliseconds;
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    String? rawMessage;
    
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        rawMessage = message;
      } else if (message is List) {
        final joined = message.map((item) => item.toString()).join(', ').trim();
        if (joined.isNotEmpty) {
          rawMessage = joined;
        }
      }
    }

    if (rawMessage == null || rawMessage.isEmpty) {
      rawMessage = error.message?.trim().isNotEmpty == true
          ? error.message!.trim()
          : 'API 요청에 실패했습니다.';
    }

    return _translateErrorMessage(rawMessage);
  }

  static const _sensitiveFields = {'password', 'passwordHash', 'refreshToken', 'accessToken'};

  Object? _sanitizeBody(Object? body) {
    if (body is! Map<String, dynamic>) return body;
    return {
      for (final entry in body.entries)
        entry.key: _sensitiveFields.contains(entry.key) ? '***' : entry.value,
    };
  }

  String _translateErrorMessage(String rawMessage) {
    final message = rawMessage.trim().toLowerCase();
    
    if (message.contains('invalid email or password') || 
        message.contains('invalid credentials') ||
        message.contains('password is incorrect') ||
        message.contains('email is incorrect')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다. 다시 확인해 주세요.';
    }
    if (message.contains('email already in use') || 
        message.contains('email already exists')) {
      return '이미 등록된 이메일 주소입니다. 다른 이메일을 사용해 주세요.';
    }
    if (message.contains('nickname already in use') || 
        message.contains('nickname already exists')) {
      return '이미 사용 중인 닉네임입니다. 다른 닉네임을 입력해 주세요.';
    }
    if (message.contains('weak password') || 
        message.contains('password is too weak')) {
      return '비밀번호가 다소 안전하지 않습니다. 8자 이상의 안전한 비밀번호를 설정해 주세요.';
    }
    if (message.contains('invalid email format') || 
        message.contains('email must be an email')) {
      return '올바른 이메일 형식이 아닙니다. 이메일 주소를 다시 확인해 주세요.';
    }
    if (message.contains('unauthorized') || 
        message.contains('session expired') || 
        message.contains('forbidden') ||
        message.contains('invalid token')) {
      return '인증 정보가 만료되었습니다. 다시 로그인해 주세요.';
    }
    if (message.contains('user not found') || 
        message.contains('player not found') ||
        message.contains('match not found') ||
        message.contains('team not found')) {
      return '찾으시는 정보를 확인할 수 없습니다. 다시 시도하거나 관리자에게 문의해 주세요.';
    }
    if (message.contains('network') || 
        message.contains('connection') || 
        message.contains('timeout') ||
        message.contains('host')) {
      return '네트워크 연결이 불안정합니다. 인터넷 연결 상태를 확인 후 다시 시도해 주세요.';
    }

    return rawMessage;
  }
}
