import '../models/auth_session.dart';
import '../models/student.dart';

class AuthService {
  const AuthService();

  Future<AuthSession> login({
    required String studentNumber,
    required String password,
  }) async {
    final number = studentNumber.trim();
    final rawPassword = password.trim();

    if (number.isEmpty || rawPassword.isEmpty) {
      throw const AuthException(
        message: 'Öğrenci numarası ve şifre zorunlu.',
        code: 'validation_error',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (_isMockFailurePassword(rawPassword)) {
      throw const AuthException(
        message: 'Öğrenci numarası veya şifre hatalı.',
        code: 'invalid_credentials',
      );
    }

    return AuthSession(
      student: Student(
        name: 'Demo Ogrenci',
        number: number,
        department: 'Bilgisayar Muhendisligi',
      ),
      token: 'mock-token-$number',
    );
  }

  bool _isMockFailurePassword(String password) {
    final normalized = password.toLowerCase();
    return normalized == 'wrong' ||
        normalized == 'hata' ||
        normalized == 'fail';
  }
}

class AuthException implements Exception {
  const AuthException({
    required this.message,
    required this.code,
    this.retryAfterSeconds,
  });

  final String message;
  final String code;
  final int? retryAfterSeconds;

  @override
  String toString() => message;
}
