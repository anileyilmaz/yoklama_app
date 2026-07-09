class AttendanceRecord {
  const AttendanceRecord({
    required this.lesson,
    required this.date,
    required this.time,
    required this.joined,
  });

  final String lesson;
  final String date;
  final String time;
  final bool joined;
}
