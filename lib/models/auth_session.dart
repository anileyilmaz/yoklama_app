import 'student.dart';

class AuthSession {
  const AuthSession({required this.student, required this.token});

  final Student student;
  final String token;
}
