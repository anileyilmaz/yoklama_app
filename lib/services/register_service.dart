import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/department.dart';
import '../models/faculty.dart';
import 'api_config.dart';

class RegisterService {
  const RegisterService({http.Client? client}) : this._(client);

  const RegisterService._(this._client);

  final http.Client? _client;

  /// Kayıt ekranındaki fakülte açılır listesini doldurur — kimlik doğrulaması
  /// gerekmez (bkz. GET /api/mobile/faculties, kayıt öncesi çağrılır).
  Future<List<Faculty>> fetchFaculties() async {
    final client = _client ?? http.Client();
    final response = await client
        .get(_endpoint('/faculties'))
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const RegisterException('Fakülte listesi alınamadı.');
    }

    final decoded = _decode(response.body);
    final list = decoded is List ? decoded : const [];
    return list.whereType<Map<String, dynamic>>().map(_facultyFromJson).toList();
  }

  Faculty _facultyFromJson(Map<String, dynamic> data) {
    return Faculty(
      id: (data['id'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? '',
    );
  }

  /// Seçilen fakülteye bağlı bölüm/program açılır listesini doldurur — kimlik
  /// doğrulaması gerekmez (bkz. GET /api/mobile/departments).
  Future<List<Department>> fetchDepartments(int facultyId) async {
    final client = _client ?? http.Client();
    final response = await client
        .get(_endpoint('/departments', query: {'facultyId': '$facultyId'}))
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const RegisterException('Bölüm listesi alınamadı.');
    }

    final decoded = _decode(response.body);
    final list = decoded is List ? decoded : const [];
    return list.whereType<Map<String, dynamic>>().map(_departmentFromJson).toList();
  }

  Department _departmentFromJson(Map<String, dynamic> data) {
    return Department(
      id: (data['id'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? '',
    );
  }

  Object? _decode(String source) {
    if (source.trim().isEmpty) return null;
    try {
      return jsonDecode(source);
    } on FormatException {
      return null;
    }
  }

  Future<String> register({
    required String name,
    required String studentNumber,
    required String department,
    required String password,
    required int facultyId,
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
            'password': password,
            'facultyId': facultyId,
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

  Uri _endpoint(String path, {Map<String, String>? query}) {
    final base = Uri.parse(ApiConfig.baseUrl);
    return base.replace(
      path: _joinPath(base.path, path),
      queryParameters: query,
    );
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
