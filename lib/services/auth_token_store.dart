import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthTokenStore {
  Future<void> saveToken(String token);

  Future<String?> readToken();

  Future<void> clearToken();
}

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore([this._storage = const FlutterSecureStorage()]);

  static const _tokenKey = 'auth_token';

  // Web'de flutter_secure_storage şifreleme için crypto.subtle kullanır, bu da
  // yalnızca "secure context"te (HTTPS veya localhost) mevcuttur — LAN IP + http
  // üzerinden test ederken crypto.subtle undefined olduğundan hata fırlatır. Test
  // amaçlı web derlemesinde belleğe düşüyoruz (sayfa yenilenince oturum sıfırlanır);
  // gerçek mobil (iOS/Android) derlemede davranış değişmez.
  static String? _webMemoryToken;

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) {
    if (kIsWeb) {
      _webMemoryToken = token;
      return Future.value();
    }
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> readToken() {
    if (kIsWeb) return Future.value(_webMemoryToken);
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() {
    if (kIsWeb) {
      _webMemoryToken = null;
      return Future.value();
    }
    return _storage.delete(key: _tokenKey);
  }
}
