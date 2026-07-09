class AttendanceRecord {
  const AttendanceRecord({
    required this.courseId,
    required this.lesson,
    required this.date,
    required this.time,
    required this.joined,
  });

  final int? courseId;
  final String lesson;
  final String date;
  final String time;
  final bool joined;
}
