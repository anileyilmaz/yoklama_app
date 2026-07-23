import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/staff_auth_session.dart';
import '../models/staff_user.dart';
import '../models/student.dart';
import '../models/unified_login_result.dart';
import 'api_config.dart';
import 'device_id_store.dart';

/// Ege SSO ekranındaki domain açılır listesinin karşılığı — yalnızca rol seçici,
/// gerçek bir domain/e-posta doğrulaması yok (bkz. tasarım dokümanı).
const kStaffLoginDomain = 'ege.edu.tr';
const kStudentLoginDomain = 'ogrenci.ege.edu.tr';

class UnifiedLoginService {
  const UnifiedLoginService({
    http.Client? client,
    DeviceIdStore deviceIdStore = const SecureDeviceIdStore(),
  }) : this._(client, deviceIdStore);

  const UnifiedLoginService._(this._client, this._deviceIdStore);

  final http.Client? _client;
  final DeviceIdStore _deviceIdStore;

  Future<UnifiedLoginResult> login({
    required String value,
    required String domain,
    required String password,
  }) async {
    final trimmedValue = value.trim();
    final rawPassword = password.trim();

    if (trimmedValue.isEmpty || rawPassword.isEmpty) {
      throw const UnifiedLoginException(
        message: 'Kullanıcı adı ve şifre zorunlu.',
        code: 'validation_error',
      );
    }

    final identifier = '$trimmedValue@$domain';
    final deviceId = domain == kStudentLoginDomain
        ? await _deviceIdStore.getOrCreateDeviceId()
        : null;

    final client = _client ?? http.Client();
    final response = await client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/unified-login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'identifier': identifier,
            'password': rawPassword,
            if (deviceId != null) 'deviceId': deviceId,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const UnifiedLoginException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const UnifiedLoginException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const UnifiedLoginException(
            message: 'Sunucuya ulaşılamıyor',
            code: 'network_error',
          );
        });

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['token'] == null) {
      throw UnifiedLoginException.fromResponse(body);
    }

    final token = body['token'] as String;

    if (body['kind'] == 'student') {
      final studentData = body['student'] as Map<String, dynamic>? ?? const {};
      return StudentLoginResult(
        AuthSession(
          student: Student(
            name: studentData['name'] as String? ?? 'Öğrenci',
            number: studentData['studentNumber'] as String? ?? trimmedValue,
            department: studentData['department'] as String? ?? '',
          ),
          token: token,
        ),
      );
    }

    return StaffLoginResult(
      StaffAuthSession(
        staffUser: StaffUser(
          username: trimmedValue,
          name: body['name'] as String? ?? trimmedValue,
          role: body['role'] as String? ?? '',
          facultyId: (body['facultyId'] as num?)?.toInt(),
          facultyName: body['facultyName'] as String?,
        ),
        token: token,
      ),
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

class UnifiedLoginException implements Exception {
  const UnifiedLoginException({
    required this.message,
    required this.code,
    this.retryAfterSeconds,
  });

  factory UnifiedLoginException.fromResponse(Map<String, dynamic> body) {
    return UnifiedLoginException(
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
