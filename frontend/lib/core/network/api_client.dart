abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) decoder,
  });

  Future<void> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });
}
