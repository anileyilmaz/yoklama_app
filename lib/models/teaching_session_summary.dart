class TeachingSessionSummary {
  const TeachingSessionSummary({
    required this.id,
    required this.courseName,
    required this.createdAt,
    required this.endedAt,
    required this.gps,
    required this.count,
  });

  final int id;
  final String courseName;
  final String createdAt;
  final String? endedAt;
  final bool gps;
  final int count;
}
