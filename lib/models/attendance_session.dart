import 'dart:convert';

class AttendanceSession {
  const AttendanceSession({
    required this.sessionCode,
    this.lesson,
    this.teacher,
    this.expiresAt,
  });

  final String sessionCode;
  final String? lesson;
  final String? teacher;
  final DateTime? expiresAt;

  static AttendanceSession fromQr(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('QR kod bos geldi.');
    }

    try {
      final decoded = jsonDecode(trimmed) as Map<String, dynamic>;
      return AttendanceSession(
        sessionCode:
            (decoded['sessionCode'] ?? decoded['session_id'] ?? decoded['id'])
                .toString(),
        lesson: decoded['lesson'] as String?,
        teacher: decoded['teacher'] as String?,
        expiresAt: decoded['expiresAt'] == null
            ? null
            : DateTime.tryParse(decoded['expiresAt'].toString()),
      );
    } on Object {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.queryParameters['session'] != null) {
        return AttendanceSession(
          sessionCode: uri.queryParameters['session']!,
          lesson: uri.queryParameters['lesson'],
          teacher: uri.queryParameters['teacher'],
        );
      }

      return AttendanceSession(sessionCode: trimmed);
    }
  }
}
