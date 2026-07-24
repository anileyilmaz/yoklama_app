import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/attendance_report.dart';
import 'api_config.dart';
import 'auth_token_store.dart';
import 'session_expiry_notifier.dart';

class AttendanceReportService {
  const AttendanceReportService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const AttendanceReportService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<AttendanceReport> fetchReport(int courseId) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const AttendanceReportException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final client = _client ?? http.Client();
    final response = await client
        .get(
          Uri.parse('${ApiConfig.staffBaseUrl}/my-courses/$courseId/report'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const AttendanceReportException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const AttendanceReportException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const AttendanceReportException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode == 401) {
      SessionExpiryNotifier.instance.notify();
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AttendanceReportException('Devamsızlık raporu alınamadı.');
    }

    final studentsSource = body['students'];
    final students = studentsSource is List ? studentsSource : const [];

    return AttendanceReport(
      totalSessions: (body['totalSessions'] as num?)?.toInt() ?? 0,
      students: students
          .whereType<Map<String, dynamic>>()
          .map(_rowFromJson)
          .toList(),
    );
  }

  AttendanceReportRow _rowFromJson(Map<String, dynamic> data) {
    return AttendanceReportRow(
      name: data['name'] as String? ?? '',
      studentNumber: data['student_number'] as String? ?? '',
      attended: (data['attended'] as num?)?.toInt() ?? 0,
      percent: (data['percent'] as num?)?.toInt(),
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

class AttendanceReportException implements Exception {
  const AttendanceReportException(this.message);

  final String message;

  @override
  String toString() => message;
}
