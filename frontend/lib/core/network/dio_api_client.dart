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
    required T Function(dynamic data) decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return decoder(response.data);
    } on DioException catch (error) {
      throw AppFailure(_messageFromDio(error));
    } catch (_) {
      throw const AppFailure('API 요청 처리 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      throw AppFailure(_messageFromDio(error));
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
