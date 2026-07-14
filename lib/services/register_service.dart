import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class RegisterService {
  const RegisterService({http.Client? client}) : this._(client);

  const RegisterService._(this._client);

  final http.Client? _client;

  Future<String> register({
    required String name,
    required String studentNumber,
    required String department,
    required int classYear,
    required String password,
  }) async {
    final client = _client ?? http.Client();
    final response = await client
        .post(
          _endpoint('/register'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name.trim(),
            'studentNumber': studentNumber.trim(),
            'department': department.trim(),
            'classYear': classYear,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const RegisterException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const RegisterException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const RegisterException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RegisterException(
        _stringValue(body['message']) ??
            _stringValue(body['error']) ??
            'Kayıt oluşturulamadı. Lütfen tekrar deneyin.',
      );
    }

    return _stringValue(body['message']) ?? 'Kaydınız alındı.';
  }

  Uri _endpoint(String path) {
    final base = Uri.parse(ApiConfig.baseUrl);
    return base.replace(path: _joinPath(base.path, path));
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

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }
}

class RegisterException implements Exception {
  const RegisterException(this.message);

  final String message;

  @override
  String toString() => message;
}
