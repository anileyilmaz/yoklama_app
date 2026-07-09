class AttendanceResult {
  const AttendanceResult({
    required this.title,
    required this.message,
    required this.lesson,
    required this.date,
    required this.time,
  });

  final String title;
  final String message;
  final String lesson;
  final String date;
  final String time;

  factory AttendanceResult.success({String? lesson, String? message}) {
    final now = DateTime.now();
    return AttendanceResult(
      title: 'Yoklama Gönderildi!',
      message: message?.isNotEmpty == true
          ? message!
          : 'Yoklamanız başarıyla kaydedildi.',
      lesson: lesson?.isNotEmpty == true ? lesson! : 'Ders bilgisi yok',
      date: _date(now),
      time: _time(now),
    );
  }

  static String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  static String _time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
