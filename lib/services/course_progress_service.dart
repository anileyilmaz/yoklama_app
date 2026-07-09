import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/course_progress.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class CourseProgressService {
  const CourseProgressService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const CourseProgressService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<List<CourseProgress>> fetchCourses() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const CourseProgressException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .get(_endpoint('/courses'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const CourseProgressException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const CourseProgressException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const CourseProgressException('Sunucuya ulaşılamıyor');
        });

    final decoded = _decode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : const {};

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw CourseProgressException(
        body['message'] as String? ??
            body['error'] as String? ??
            'Ders listesi alınamadı.',
      );
    }

    final source = body['data'] ?? decoded;
    final list = source is List ? source : const [];

    return list.whereType<Map<String, dynamic>>().map(_courseFromJson).toList();
  }

  CourseProgress _courseFromJson(Map<String, dynamic> data) {
    return CourseProgress(
      courseId: (data['courseId'] as num?)?.toInt() ?? 0,
      course: data['course'] as String? ?? 'Ders bilgisi yok',
      attended: (data['attended'] as num?)?.toInt() ?? 0,
      totalSessions: (data['totalSessions'] as num?)?.toInt() ?? 0,
      percent: (data['percent'] as num?)?.toInt(),
      atRisk: data['atRisk'] == true,
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

  Object? _decode(String source) {
    if (source.trim().isEmpty) return const {};
    try {
      return jsonDecode(source);
    } on FormatException {
      return const {};
    }
  }
}

class CourseProgressException implements Exception {
  const CourseProgressException(this.message);

  final String message;

  @override
  String toString() => message;
}
