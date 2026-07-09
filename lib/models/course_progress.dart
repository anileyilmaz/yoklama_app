class CourseProgress {
  const CourseProgress({
    required this.courseId,
    required this.course,
    required this.attended,
    required this.totalSessions,
    required this.percent,
    required this.atRisk,
  });

  final int courseId;
  final String course;
  final int attended;
  final int totalSessions;

  /// Hiç oturum açılmamışsa `null`.
  final int? percent;

  /// Katılım oranı sunucudaki eşiğin (bkz. `ATTENDANCE_RISK_THRESHOLD`,
  /// server.js) altına düştüğünde `true`.
  final bool atRisk;
}
