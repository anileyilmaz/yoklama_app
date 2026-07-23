import 'package:flutter_test/flutter_test.dart';
import 'package:yoklama_app/models/auth_session.dart';
import 'package:yoklama_app/models/staff_auth_session.dart';
import 'package:yoklama_app/models/staff_user.dart';
import 'package:yoklama_app/models/student.dart';
import 'package:yoklama_app/models/unified_login_result.dart';

void main() {
  test('StudentLoginResult carries the given AuthSession', () {
    const session = AuthSession(
      student: Student(name: 'Ali', number: '123', department: 'X'),
      token: 'tok',
    );
    const result = StudentLoginResult(session);
    expect(result.session.token, 'tok');
    expect(result, isA<UnifiedLoginResult>());
  });

  test('StaffLoginResult carries the given StaffAuthSession', () {
    const session = StaffAuthSession(
      staffUser: StaffUser(username: 'hoca1', name: 'Ayşe', role: 'teacher'),
      token: 'tok2',
    );
    const result = StaffLoginResult(session);
    expect(result.session.token, 'tok2');
    expect(result, isA<UnifiedLoginResult>());
  });

  test('switch pattern matching distinguishes the two result kinds', () {
    const UnifiedLoginResult studentResult = StudentLoginResult(
      AuthSession(
        student: Student(name: 'Ali', number: '123', department: 'X'),
        token: 't',
      ),
    );
    final kind = switch (studentResult) {
      StudentLoginResult() => 'student',
      StaffLoginResult() => 'staff',
    };
    expect(kind, 'student');
  });
}
