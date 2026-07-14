class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://172.20.10.8:3000/api/mobile';

  /// socket.io sunucusu REST API'siyle aynı sunucuda ama `/api/mobile` alt
  /// yolu olmadan (kök origin'e) bağlanır.
  static String get socketOrigin {
    final uri = Uri.parse(baseUrl);
    return uri.replace(path: '').toString();
  }
}
