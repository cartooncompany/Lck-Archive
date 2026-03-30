abstract class ApiClient {
  Future<T> get<T>(String path);
}
