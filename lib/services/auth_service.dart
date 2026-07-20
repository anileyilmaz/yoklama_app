import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/student.dart';
import 'api_config.dart';
import 'device_id_store.dart';

class AuthService {
  const AuthService({http.Client? client, DeviceIdStore deviceIdStore = const SecureDeviceIdStore()})
    : this._(client, deviceIdStore);

  const AuthService._(this._client, this._deviceIdStore);

  final http.Client? _client;
  final DeviceIdStore _deviceIdStore;

  Future<AuthSession> login({
    required String studentNumber,
    required String password,
  }) async {
    final number = studentNumber.trim();
    final rawPassword = password.trim();

    if (number.isEmpty || rawPassword.isEmpty) {
      throw const AuthException(
        message: 'Öğrenci numarası ve şifre zorunlu.',
        code: 'validation_error',
      );
    }

    final deviceId = await _deviceIdStore.getOrCreateDeviceId();

    final client = _client ?? http.Client();
    final response = await client
        .post(
          _endpoint('/login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'studentNumber': number,
            'password': rawPassword,
            'deviceId': deviceId,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const AuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const AuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const AuthException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw AuthException.fromResponse(body);
    }

    final data = _asMap(body['data']) ?? body;
    final token =
        _stringValue(data['token']) ??
        _stringValue(data['accessToken']) ??
        _stringValue(body['token']) ??
        _stringValue(body['accessToken']);

    if (token == null || token.isEmpty) {
      throw const AuthException(
        message: 'Giriş yanıtında token bulunamadı.',
        code: 'missing_token',
      );
    }

    final studentData = _asMap(data['student']) ?? _asMap(body['student']);

    return AuthSession(
      student: Student(
        name:
            _stringValue(studentData?['name']) ??
            _stringValue(data['studentName']) ??
            'Öğrenci',
        number:
            _stringValue(studentData?['number']) ??
            _stringValue(studentData?['studentNumber']) ??
            _stringValue(data['studentNumber']) ??
            number,
        department:
            _stringValue(studentData?['department']) ??
            _stringValue(data['department']) ??
            '',
      ),
      token: token,
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

class AuthException implements Exception {
  const AuthException({
    required this.message,
    required this.code,
    this.retryAfterSeconds,
  });

  factory AuthException.fromResponse(Map<String, dynamic> body) {
    return AuthException(
      message:
          body['message'] as String? ??
          body['error'] as String? ??
          'Giriş yapılamadı. Lütfen tekrar deneyin.',
      code: body['code'] as String? ?? 'login_failed',
      retryAfterSeconds: body['retryAfterSeconds'] is num
          ? (body['retryAfterSeconds'] as num).toInt()
          : null,
    );
  }

  final String message;
  final String code;
  final int? retryAfterSeconds;

  @override
  String toString() => message;
}
