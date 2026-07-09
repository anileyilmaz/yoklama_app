import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthTokenStore {
  Future<void> saveToken(String token);

  Future<String?> readToken();

  Future<void> clearToken();
}

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore([this._storage = const FlutterSecureStorage()]);

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }
}
