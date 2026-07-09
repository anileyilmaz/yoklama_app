import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/student.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class ProfileService {
  const ProfileService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const ProfileService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<Student> fetchProfile({required Student fallback}) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const ProfileException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .get(_endpoint('/profile'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const ProfileException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const ProfileException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const ProfileException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw ProfileException(
        body['message'] as String? ?? 'Profil bilgileri alınamadı.',
      );
    }

    final data = _asMap(body['data']) ?? _asMap(body['student']) ?? body;

    return Student(
      name:
          _stringValue(data['name']) ??
          _stringValue(data['studentName']) ??
          fallback.name,
      number:
          _stringValue(data['number']) ??
          _stringValue(data['studentNumber']) ??
          fallback.number,
      department: _stringValue(data['department']) ?? fallback.department,
    );
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

  Map<String, dynamic>? _asMap(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
