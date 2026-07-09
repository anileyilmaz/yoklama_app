import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/attendance_result.dart';
import '../models/attendance_session.dart';
import '../models/student.dart';

class AttendanceApi {
  const AttendanceApi();

  Future<AttendanceResult> submit({
    required Student student,
    required AttendanceSession session,
  }) async {
    if (AppConfig.apiBaseUrl.trim().isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return AttendanceResult.demo(session.sessionCode, lesson: session.lesson);
    }

    final base = Uri.parse(AppConfig.apiBaseUrl.trim());
    final endpoint = base.replace(
      path: _joinPath(base.path, '/api/attendance/check-in'),
    );

    final response = await http
        .post(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'studentName': student.name,
            'studentNumber': student.number,
            'department': student.department,
            'sessionCode': session.sessionCode,
            'lesson': session.lesson,
            'scannedAt': DateTime.now().toIso8601String(),
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AttendanceResult.success(
        session.sessionCode,
        lesson: session.lesson,
      );
    }

    throw const AttendanceException(
      'Yoklama gonderilemedi. Lutfen tekrar deneyin.',
    );
  }

  String _joinPath(String basePath, String apiPath) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase$apiPath';
  }
}

class AttendanceException implements Exception {
  const AttendanceException(this.message);

  final String message;

  @override
  String toString() => message;
}
