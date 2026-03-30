abstract class LocalStorage {
  Future<void> writeString(String key, String value);

  Future<String?> readString(String key);
}
