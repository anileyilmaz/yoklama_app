import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract class DeviceIdStore {
  Future<String> getOrCreateDeviceId();
}

// Cihaz bazlı yoklama sahtekarlığı önleme (bkz. backend README'deki aynı başlık) için
// kalıcı bir cihaz kimliği üretir/saklar. Bu key AuthTokenStore'dan tamamen ayrı bir
// key altında tutulur ve logout akışları yalnızca auth-token key'ini temizler — bu
// kimliğin logout'ta hayatta kalması özelliğin tüm amacıdır (aksi halde bir arkadaş
// çıkış yapıp kendi hesabına girdiğinde sunucu bunu "yeni cihaz" sanır).
class SecureDeviceIdStore implements DeviceIdStore {
  const SecureDeviceIdStore([this._storage = const FlutterSecureStorage()]);

  static const _deviceIdKey = 'device_id';

  // Web'de flutter_secure_storage crypto.subtle gerektirir (bkz. AuthTokenStore'daki
  // aynı not) — LAN IP + http üzerinden test ederken belleğe düşüyoruz.
  static String? _webMemoryDeviceId;

  final FlutterSecureStorage _storage;

  @override
  Future<String> getOrCreateDeviceId() async {
    if (kIsWeb) {
      _webMemoryDeviceId ??= const Uuid().v4();
      return _webMemoryDeviceId!;
    }
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }
}
