import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_token_store.dart';
import 'password_changer.dart';
import 'session_expiry_notifier.dart';

class StaffPasswordService implements PasswordChanger {
  const StaffPasswordService({
    this._tokenStore = const SecureAuthTokenStore(),
  });

  final AuthTokenStore _tokenStore;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const StaffPasswordException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final response = await http
        .post(
          Uri.parse('${ApiConfig.staffBaseUrl}/change-password'),
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
          throw const StaffPasswordException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const StaffPasswordException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const StaffPasswordException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode == 401) {
      SessionExpiryNotifier.instance.notify();
    }

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StaffPasswordException(
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

class StaffPasswordException implements Exception {
  const StaffPasswordException(this.message);

  final String message;

  @override
  String toString() => message;
}
