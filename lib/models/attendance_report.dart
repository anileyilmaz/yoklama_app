class AttendanceReportRow {
  const AttendanceReportRow({
    required this.name,
    required this.studentNumber,
    required this.attended,
    required this.percent,
  });

  final String name;
  final String studentNumber;
  final int attended;
  final int? percent;

  bool get atRisk => percent != null && percent! < 70;
}

class AttendanceReport {
  const AttendanceReport({
    required this.totalSessions,
    required this.students,
  });

  final int totalSessions;
  final List<AttendanceReportRow> students;
}
