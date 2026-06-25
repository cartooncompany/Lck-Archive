import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_storage.dart';

class SecureLocalStorage implements LocalStorage {
  const SecureLocalStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static SecureLocalStorage create() {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    return SecureLocalStorage(secureStorage);
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<String?> readString(String key) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
}
