import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yoklama_app/main.dart';
import 'package:yoklama_app/services/auth_token_store.dart';
import 'package:yoklama_app/services/session_expiry_notifier.dart';
import 'package:yoklama_app/services/unified_login_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('restores TeacherHomeShell when a teacher session was persisted', (
    tester,
  ) async {
    final tokenStore = _FakeAuthTokenStore();
    await tokenStore.saveToken('fake-teacher-token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', 'teacher');
    await prefs.setString(
      'staffUser',
      '{"username":"hoca1","name":"Ayşe Hoca","role":"teacher","facultyId":null,"facultyName":null}',
    );

    await tester.pumpWidget(AttendanceApp(tokenStore: tokenStore));
    await tester.pump();
    await tester.pump();

    expect(find.text('Ayşe Hoca'), findsNothing); // henüz profil sekmesinde değil
    expect(find.text('Derslerim'), findsWidgets); // ama TeacherHomeShell açıldı
  });

  testWidgets(
    'a 401 from any service (SessionExpiryNotifier) logs a restored teacher session out',
    (tester) async {
      final tokenStore = _FakeAuthTokenStore();
      await tokenStore.saveToken('fake-teacher-token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'teacher');
      await prefs.setString(
        'staffUser',
        '{"username":"hoca1","name":"Ayşe Hoca","role":"teacher","facultyId":null,"facultyName":null}',
      );

      await tester.pumpWidget(AttendanceApp(tokenStore: tokenStore));
      await tester.pump();
      await tester.pump();
      expect(find.text('Derslerim'), findsWidgets); // TeacherHomeShell açık

      SessionExpiryNotifier.instance.notify();
      await tester.pumpAndSettle();

      expect(find.text('Derslerim'), findsNothing);
      expect(find.text('Kullanıcı adınız'), findsOneWidget); // LoginScreen'e düştü
      expect(await tokenStore.readToken(), isNull);
    },
  );

  testWidgets('shows the unified LoginScreen after tapping Başlayalım', (
    tester,
  ) async {
    await tester.pumpWidget(AttendanceApp(tokenStore: _FakeAuthTokenStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Başlayalım'));
    await tester.pumpAndSettle();

    expect(find.text('Kullanıcı adınız'), findsOneWidget);
    expect(find.text(kStudentLoginDomain), findsOneWidget);
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
