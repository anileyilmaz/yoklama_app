import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/staff_auth_session.dart';
import '../models/staff_user.dart';
import 'api_config.dart';

class StaffAuthService {
  const StaffAuthService({http.Client? client}) : this._(client);

  const StaffAuthService._(this._client);

  final http.Client? _client;

  Future<StaffAuthSession> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final rawPassword = password.trim();

    if (trimmedUsername.isEmpty || rawPassword.isEmpty) {
      throw const StaffAuthException(
        message: 'Kullanıcı adı ve şifre zorunlu.',
        code: 'validation_error',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .post(
          Uri.parse('${ApiConfig.staffBaseUrl}/login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': trimmedUsername,
            'password': rawPassword,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const StaffAuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const StaffAuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const StaffAuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['token'] == null) {
      throw StaffAuthException.fromResponse(body);
    }

    return StaffAuthSession(
      staffUser: StaffUser(
        username: trimmedUsername,
        name: body['name'] as String? ?? trimmedUsername,
        role: body['role'] as String? ?? '',
        facultyId: (body['facultyId'] as num?)?.toInt(),
        facultyName: body['facultyName'] as String?,
      ),
      token: body['token'] as String,
    );
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

class StaffAuthException implements Exception {
  const StaffAuthException({required this.message, required this.code});

  factory StaffAuthException.fromResponse(Map<String, dynamic> body) {
    return StaffAuthException(
      message:
          body['message'] as String? ??
          body['error'] as String? ??
          'Giriş yapılamadı. Lütfen tekrar deneyin.',
      code: body['code'] as String? ?? 'login_failed',
    );
  }

  final String message;
  final String code;

  @override
  String toString() => message;
}
