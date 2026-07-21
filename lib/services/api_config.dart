class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://172.20.10.8:3000/api/mobile';

  /// Hoca/admin JSON API'si aynı sunucuda ama `/api/mobile` değil `/api` kökünde
  /// yaşıyor (bkz. backend server.js — /api/login, /api/my-courses, /api/sessions*
  /// vb.). `/api/mobile` sabitini `/api`'ye indirger, host/port aynı kalır.
  static String get staffBaseUrl => baseUrl.replaceFirst('/api/mobile', '/api');

  /// socket.io sunucusu REST API'siyle aynı sunucuda ama `/api/mobile` alt
  /// yolu olmadan (kök origin'e) bağlanır.
  static String get socketOrigin {
    final uri = Uri.parse(baseUrl);
    return uri.replace(path: '').toString();
  }
}
