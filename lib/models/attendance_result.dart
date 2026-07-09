class AttendanceResult {
  const AttendanceResult({
    required this.title,
    required this.message,
    required this.lesson,
    required this.date,
    required this.time,
    required this.isDemo,
  });

  final String title;
  final String message;
  final String lesson;
  final String date;
  final String time;
  final bool isDemo;

  factory AttendanceResult.success(String code, {String? lesson}) {
    final now = DateTime.now();
    return AttendanceResult(
      title: 'Yoklama Gonderildi!',
      message: 'Yoklamaniz basariyla kaydedildi.',
      lesson: lesson?.isNotEmpty == true ? lesson! : 'Veri Yapilari',
      date: _date(now),
      time: _time(now),
      isDemo: false,
    );
  }

  factory AttendanceResult.demo(String code, {String? lesson}) {
    final now = DateTime.now();
    return AttendanceResult(
      title: 'Yoklama Gonderildi!',
      message: 'Yoklamaniz basariyla kaydedildi.',
      lesson: lesson?.isNotEmpty == true ? lesson! : 'Veri Yapilari',
      date: _date(now),
      time: _time(now),
      isDemo: true,
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
