import 'package:dio/dio.dart';

import '../error/app_failure.dart';
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
      );

  final Dio _dio;

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
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
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
