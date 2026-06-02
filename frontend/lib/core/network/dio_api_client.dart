import 'package:dio/dio.dart';

import '../error/app_failure.dart';
import '../logging/app_logger.dart';
import 'api_client.dart';

class DioApiClient implements ApiClient {
  DioApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
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
              if (options.data != null) 'body': options.data,
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
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      if (message is List) {
        final joined = message.map((item) => item.toString()).join(', ').trim();
        if (joined.isNotEmpty) {
          return joined;
        }
      }
    }

    return error.message?.trim().isNotEmpty == true
        ? error.message!.trim()
        : 'API 요청에 실패했습니다.';
  }
}
