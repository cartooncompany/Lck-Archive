class AppFailure implements Exception {
  const AppFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() {
    return 'AppFailure(message: $message, statusCode: $statusCode)';
  }
}
