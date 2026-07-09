import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_token_store.dart';

class PasswordService {
  const PasswordService({this._tokenStore = const SecureAuthTokenStore()});

  final AuthTokenStore _tokenStore;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const PasswordException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final base = Uri.parse(ApiConfig.baseUrl.trim());
    final endpoint = base.replace(
      path: _joinPath(base.path, '/change-password'),
    );

    final response = await http
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const PasswordException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const PasswordException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const PasswordException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PasswordException(
        body['message'] as String? ??
            body['error'] as String? ??
            'Şifre değiştirilemedi. Lütfen tekrar deneyin.',
      );
    }

    final newToken = body['token'] as String?;
    if (newToken != null && newToken.isNotEmpty) {
      await _tokenStore.saveToken(newToken);
    }
  }

  String _joinPath(String basePath, String path) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }

  Map<String, dynamic> _decodeBody(String source) {
    if (source.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}

class PasswordException implements Exception {
  const PasswordException(this.message);

  final String message;

  @override
  String toString() => message;
}
