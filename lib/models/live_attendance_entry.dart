class LiveAttendanceEntry {
  const LiveAttendanceEntry({
    required this.name,
    required this.studentNumber,
    required this.department,
    required this.createdAt,
    required this.manual,
  });

  final String name;
  final String studentNumber;
  final String department;
  final String createdAt;
  final bool manual;

  factory LiveAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return LiveAttendanceEntry(
      name: json['name'] as String? ?? '',
      studentNumber: json['student_number'] as String? ?? '',
      department: json['department'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      manual: json['manual'] == true || json['manual'] == 1,
    );
  }
}
