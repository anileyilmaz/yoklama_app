import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/teaching_session_detail.dart';
import '../models/teaching_session_summary.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class TeacherSessionService {
  const TeacherSessionService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const TeacherSessionService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<int> startSession({
    required int courseId,
    double? lat,
    double? lng,
    int? radius,
  }) async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final requestBody = {
      'courseId': courseId,
      ...?(lat != null ? {'lat': lat} : null),
      ...?(lng != null ? {'lng': lng} : null),
      ...?(radius != null ? {'radius': radius} : null),
    };
    final response = await client
        .post(
          Uri.parse('${ApiConfig.staffBaseUrl}/sessions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TeacherSessionException(
        body['error'] as String? ?? 'Yoklama başlatılamadı.',
      );
    }
    final id = (body['id'] as num?)?.toInt();
    if (id == null) {
      throw const TeacherSessionException('Yoklama başlatılamadı.');
    }
    return id;
  }

  Future<List<TeachingSessionSummary>> fetchHistory() async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final response = await client
        .get(
          Uri.parse('${ApiConfig.staffBaseUrl}/sessions'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TeacherSessionException('Geçmiş oturumlar alınamadı.');
    }
    final decoded = _decode(response.body);
    final list = decoded is List ? decoded : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_summaryFromJson)
        .toList();
  }

  Future<TeachingSessionDetail> fetchDetail(int sessionId) async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final response = await client
        .get(
          Uri.parse('${ApiConfig.staffBaseUrl}/sessions/$sessionId'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        });

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TeacherSessionException(
        body['error'] as String? ?? 'Yoklama oturumu bulunamadı.',
      );
    }
    return _detailFromJson(body);
  }

  Future<void> endSession(int sessionId) async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final response = await client
        .post(
          Uri.parse('${ApiConfig.staffBaseUrl}/sessions/$sessionId/end'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const TeacherSessionException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TeacherSessionException('Oturum bitirilemedi.');
    }
  }

  Future<String> _requireToken() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const TeacherSessionException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }
    return token;
  }

  TeachingSessionSummary _summaryFromJson(Map<String, dynamic> data) {
    return TeachingSessionSummary(
      id: (data['id'] as num?)?.toInt() ?? 0,
      courseName: data['course_name'] as String? ?? 'Ders bilgisi yok',
      createdAt: data['created_at'] as String? ?? '',
      endedAt: data['ended_at'] as String?,
      gps: data['gps'] == true || data['gps'] == 1,
      count: (data['count'] as num?)?.toInt() ?? 0,
    );
  }

  TeachingSessionDetail _detailFromJson(Map<String, dynamic> data) {
    return TeachingSessionDetail(
      id: (data['id'] as num?)?.toInt() ?? 0,
      courseName: data['course_name'] as String? ?? 'Ders bilgisi yok',
      createdAt: data['created_at'] as String? ?? '',
      endedAt: data['ended_at'] as String?,
      gps: data['gps'] == true,
      radius: (data['radius'] as num?)?.toInt(),
      qr: data['qr'] as String?,
      qrWindowMs: (data['qrWindowMs'] as num?)?.toInt() ?? 10000,
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

  Object? _decode(String source) {
    if (source.trim().isEmpty) return const {};
    try {
      return jsonDecode(source);
    } on FormatException {
      return const {};
    }
  }
}

class TeacherSessionException implements Exception {
  const TeacherSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}
