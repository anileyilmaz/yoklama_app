import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/attendance_record.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class AttendanceHistoryService {
  const AttendanceHistoryService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const AttendanceHistoryService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<List<AttendanceRecord>> fetchHistory() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const AttendanceHistoryException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .get(
          _endpoint('/attendance/history'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const AttendanceHistoryException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const AttendanceHistoryException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const AttendanceHistoryException('Sunucuya ulaşılamıyor');
        });

    final decoded = _decode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : const {};

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw AttendanceHistoryException(
        body['message'] as String? ?? 'Yoklama geçmişi alınamadı.',
      );
    }

    final recordsSource =
        body['data'] ?? body['history'] ?? body['records'] ?? decoded;
    final records = recordsSource is List ? recordsSource : const [];

    return records
        .whereType<Map<String, dynamic>>()
        .map(_recordFromJson)
        .toList();
  }

  AttendanceRecord _recordFromJson(Map<String, dynamic> data) {
    return AttendanceRecord(
      lesson:
          _stringValue(data['lesson']) ??
          _stringValue(data['courseName']) ??
          _stringValue(data['course']) ??
          _stringValue(data['title']) ??
          'Ders bilgisi yok',
      date:
          _stringValue(data['date']) ??
          _stringValue(data['day']) ??
          _formatDate(data['createdAt']) ??
          _formatDate(data['scannedAt']) ??
          '',
      time:
          _stringValue(data['time']) ??
          _stringValue(data['hour']) ??
          _formatTime(data['createdAt']) ??
          _formatTime(data['scannedAt']) ??
          '',
      joined:
          _boolValue(data['joined']) ??
          _boolValue(data['attended']) ??
          _boolValue(data['success']) ??
          true,
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

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'joined' ||
          normalized == 'attended' ||
          normalized == 'katildi' ||
          normalized == 'katıldı' ||
          normalized == 'true') {
        return true;
      }
      if (normalized == 'missed' ||
          normalized == 'absent' ||
          normalized == 'false') {
        return false;
      }
    }
    return null;
  }

  String? _formatDate(Object? source) {
    final date = _parseDate(source);
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String? _formatTime(Object? source) {
    final date = _parseDate(source);
    if (date == null) return null;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(Object? source) {
    final value = _stringValue(source);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}

class AttendanceHistoryException implements Exception {
  const AttendanceHistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
