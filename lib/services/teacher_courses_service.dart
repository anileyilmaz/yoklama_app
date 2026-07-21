import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/teacher_course.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class TeacherCoursesService {
  const TeacherCoursesService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const TeacherCoursesService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<List<TeacherCourse>> fetchCourses() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const TeacherCoursesException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .get(
          Uri.parse('${ApiConfig.staffBaseUrl}/my-courses'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const TeacherCoursesException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const TeacherCoursesException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const TeacherCoursesException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TeacherCoursesException('Ders listesi alınamadı.');
    }

    final decoded = _decode(response.body);
    final list = decoded is List ? decoded : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_courseFromJson)
        .toList();
  }

  TeacherCourse _courseFromJson(Map<String, dynamic> data) {
    return TeacherCourse(
      id: (data['id'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? 'Ders bilgisi yok',
      enrolled: (data['enrolled'] as num?)?.toInt() ?? 0,
    );
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

class TeacherCoursesException implements Exception {
  const TeacherCoursesException(this.message);

  final String message;

  @override
  String toString() => message;
}
