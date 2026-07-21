import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/staff_user.dart';
import 'package:yoklama_app/screens/teacher_home_shell.dart';

void main() {
  const staffUser = StaffUser(
    username: 'hoca1',
    name: 'Ayşe Hoca',
    role: 'teacher',
  );

  // TeacherHomeShell'in initState'i gerçek TeacherCoursesService/
  // TeacherSessionService'i (dolayısıyla SecureAuthTokenStore'u) çağırıyor.
  // flutter_secure_storage'ın gerçek platform kanalı widget test ortamında
  // (host'ta gerçek bir platform implementasyonu olmadan) hiç yanıt vermiyor,
  // bu da CircularProgressIndicator'ı sonsuza dek döndürüp pumpAndSettle'ı
  // timeout'a düşürüyor. Paketin kendi resmi test double'ı
  // (`TestFlutterSecureStoragePlatform`) ile platformu değiştirip token
  // okumasının hemen (boş) tamamlanmasını sağlıyoruz — bu üretim kodunu
  // etkilemez, sadece test ortamındaki eksik platform implementasyonunu telafi eder.
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  testWidgets('switching tabs shows the right screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherHomeShell(
          staffUser: staffUser,
          onLogout: () {},
          darkMode: false,
          onDarkModeChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Derslerim'), findsWidgets);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Ayşe Hoca'), findsOneWidget);
  });
}
