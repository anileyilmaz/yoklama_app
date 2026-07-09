class ActiveSession {
  const ActiveSession({
    required this.sessionId,
    required this.courseId,
    required this.courseName,
  });

  final int sessionId;
  final int courseId;
  final String courseName;

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      sessionId: (json['sessionId'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      courseName: json['courseName'] as String? ?? 'Ders bilgisi yok',
    );
  }
}
