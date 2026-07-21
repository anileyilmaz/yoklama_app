class TeachingSessionDetail {
  const TeachingSessionDetail({
    required this.id,
    required this.courseName,
    required this.createdAt,
    required this.endedAt,
    required this.gps,
    required this.radius,
    required this.qr,
    required this.qrWindowMs,
  });

  final int id;
  final String courseName;
  final String createdAt;
  final String? endedAt;
  final bool gps;
  final int? radius;
  final String? qr;
  final int qrWindowMs;
}
