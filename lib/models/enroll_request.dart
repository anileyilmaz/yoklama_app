class EnrollRequest {
  const EnrollRequest({
    required this.id,
    required this.name,
    required this.studentNumber,
    required this.department,
  });

  final int id;
  final String name;
  final String studentNumber;
  final String department;

  // Bu model iki farklı kaynaktan besleniyor ve ikisinin anahtar adları farklı:
  // REST (GET .../enroll-requests) -> id, student_number (snake_case)
  // socket.io "enrollRequest" event'i -> requestId, studentNumber (camelCase)
  factory EnrollRequest.fromJson(Map<String, dynamic> json) {
    return EnrollRequest(
      id: ((json['id'] as num?) ?? (json['requestId'] as num?))?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      studentNumber:
          json['student_number'] as String? ??
          json['studentNumber'] as String? ??
          '',
      department: json['department'] as String? ?? '',
    );
  }
}
