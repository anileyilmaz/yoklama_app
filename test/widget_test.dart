import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yoklama_app/main.dart';
import 'package:yoklama_app/models/attendance_session.dart';
import 'package:yoklama_app/services/auth_token_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows welcome screen first', (WidgetTester tester) async {
    await tester.pumpWidget(AttendanceApp(tokenStore: _FakeAuthTokenStore()));
    await tester.pumpAndSettle();

    expect(find.text('Yoklama'), findsOneWidget);
    expect(find.text('Baslayalim'), findsOneWidget);
  });

  test('parses plain QR session code', () {
    final session = AttendanceSession.fromQr('MAT101-2026-01');

    expect(session.sessionCode, 'MAT101-2026-01');
  });

  test('parses JSON QR payload', () {
    final session = AttendanceSession.fromQr(
      '{"sessionCode":"ABC123","lesson":"Mobil Programlama","teacher":"Hoca"}',
    );

    expect(session.sessionCode, 'ABC123');
    expect(session.lesson, 'Mobil Programlama');
    expect(session.teacher, 'Hoca');
  });
}

class _FakeAuthTokenStore implements AuthTokenStore {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }
}
