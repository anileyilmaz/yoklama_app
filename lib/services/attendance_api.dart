import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/attendance_result.dart';
import '../models/attendance_session.dart';
import '../models/student.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class AttendanceApi {
  const AttendanceApi({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
  }) : this._(tokenStore);

  const AttendanceApi._(this._tokenStore);

  final AuthTokenStore _tokenStore;

  Future<AttendanceResult> submit({
    required Student student,
    required AttendanceSession session,
    required String qr,
  }) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const AttendanceException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final base = Uri.parse(ApiConfig.baseUrl.trim());
    final endpoint = base.replace(
      path: _joinPath(base.path, '/attendance/scan'),
    );

    final response = await http
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'qr': qr, 'lat': null, 'lng': null}),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] != false) {
      return AttendanceResult.success(
        lesson: _successLesson(body, session.lesson),
        message: _stringValue(body['message']),
      );
    }

    throw AttendanceException(
      _stringValue(body['message']) ??
          'Yoklama gönderilemedi. Lütfen tekrar deneyin.',
    );
  }

  String _joinPath(String basePath, String apiPath) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase$apiPath';
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

  String? _successLesson(Map<String, dynamic> body, String? fallback) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return _stringValue(data['lesson']) ??
          _stringValue(data['courseName']) ??
          _stringValue(data['course']) ??
          fallback;
    }
    return fallback;
  }

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }
}

class AttendanceException implements Exception {
  const AttendanceException(this.message);

  final String message;

  @override
  String toString() => message;
}
