import 'package:flutter_test/flutter_test.dart';
import 'package:yoklama_app/models/enroll_request.dart';

void main() {
  test('parses the REST shape (id, student_number)', () {
    final request = EnrollRequest.fromJson(const {
      'id': 5,
      'name': 'Ali Veli',
      'student_number': '210101234',
      'department': 'Bilgisayar Mühendisliği',
      'created_at': '2026-07-21 10:00:00',
    });

    expect(request.id, 5);
    expect(request.name, 'Ali Veli');
    expect(request.studentNumber, '210101234');
    expect(request.department, 'Bilgisayar Mühendisliği');
  });

  test('parses the socket.io "enrollRequest" event shape (requestId, studentNumber)', () {
    final request = EnrollRequest.fromJson(const {
      'requestId': 7,
      'studentId': 42,
      'name': 'Ayşe Yılmaz',
      'studentNumber': '210105678',
      'department': 'Elektrik-Elektronik Mühendisliği',
    });

    expect(request.id, 7);
    expect(request.name, 'Ayşe Yılmaz');
    expect(request.studentNumber, '210105678');
  });
}
