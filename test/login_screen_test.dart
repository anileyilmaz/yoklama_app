import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:yoklama_app/models/unified_login_result.dart';
import 'package:yoklama_app/screens/login_screen.dart';
import 'package:yoklama_app/services/unified_login_service.dart';

void main() {
  // Öğrenci domaininde her girişte SecureDeviceIdStore -> flutter_secure_storage
  // çağrılıyor; gerçek platform kanalı widget test ortamında hiç yanıt vermediği
  // için (bkz. test/teacher_home_shell_test.dart'taki aynı not) CircularProgressIndicator
  // sonsuza dek dönüp pumpAndSettle'ı timeout'a düşürür. Paketin resmi test double'ı ile
  // bunu telafi ediyoruz — üretim kodunu etkilemez.
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  testWidgets('defaults to student mode: shows remember-me and register link', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(onSaved: (_, _) async {})),
    );

    expect(find.text('Kullanıcı adınız'), findsOneWidget);
    expect(find.text('Beni hatırla'), findsOneWidget);
    expect(find.text('Hesabın yok mu? Kayıt ol'), findsOneWidget);
    expect(find.text('Öğrenci girişi'), findsOneWidget);
  });

  testWidgets(
    'switching domain to ege.edu.tr hides student-only fields but keeps remember-me',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(onSaved: (_, _) async {})),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kStaffLoginDomain).last);
      await tester.pumpAndSettle();

      expect(find.text('Beni hatırla'), findsOneWidget);
      expect(find.text('Hesabın yok mu? Kayıt ol'), findsNothing);
      expect(find.text('Öğretim üyesi girişi'), findsOneWidget);
    },
  );

  testWidgets(
    'student domain: successful login calls onSaved with StudentLoginResult',
    (tester) async {
      UnifiedLoginResult? received;
      bool? receivedRememberMe;

      final service = UnifiedLoginService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'kind': 'student',
              'token': 'tok',
              'student': {
                'id': 1,
                'name': 'Ali Veli',
                'studentNumber': '210101234',
                'department': 'X',
              },
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            loginService: service,
            onSaved: (result, rememberMe) async {
              received = result;
              receivedRememberMe = rememberMe;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), '210101234');
      await tester.enterText(find.byType(TextFormField).at(1), 'sifre123');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      expect(received, isA<StudentLoginResult>());
      expect(receivedRememberMe, isTrue);
    },
  );

  testWidgets(
    'staff domain, teacher role: successful login calls onSaved with StaffLoginResult',
    (tester) async {
      UnifiedLoginResult? received;

      final service = UnifiedLoginService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'kind': 'staff',
              'token': 'tok',
              'role': 'teacher',
              'name': 'Ayşe Hoca',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            loginService: service,
            onSaved: (result, _) async => received = result,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kStaffLoginDomain).last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'hoca1');
      await tester.enterText(find.byType(TextFormField).at(1), 'sifre123');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      expect(received, isA<StaffLoginResult>());
    },
  );

  testWidgets(
    'staff domain, admin role: blocked with a snackbar, onSaved not called',
    (tester) async {
      var onSavedCalled = false;

      final service = UnifiedLoginService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'kind': 'staff',
              'token': 'tok',
              'role': 'admin',
              'name': 'Test Admin',
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            loginService: service,
            onSaved: (_, _) async => onSavedCalled = true,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kStaffLoginDomain).last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      expect(onSavedCalled, isFalse);
      expect(
        find.text('Yönetici paneli mobil uygulamada yakında.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'failed-attempt counter resets when switching away from and back to student domain',
    (tester) async {
      // Varsayılan test viewport'u (800x600) çok kısa: buton ekranın alt
      // kenarına yakın konumlanıyor ve her hatalı denemede gösterilen
      // SnackBar (varsayılan 4 sn süreyle ekranın altına yerleşiyor) tam
      // üzerine biniyor — pumpAndSettle da yalnızca animasyon karelerini
      // bekler, SnackBar'ın kapanma Timer'ını beklemez, bu yüzden SnackBar
      // sonraki denemelerde de görünür kalıp butonu tıklanamaz hale
      // getiriyor. Gerçek cihazlarda ekran çok daha uzun olduğundan bu çakışma
      // yaşanmaz — burada yalnızca test yüzeyini büyüterek aynı şeyi sağlıyoruz
      // (üretim kodu/test iddiaları değişmiyor).
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = UnifiedLoginService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Öğrenci numarası veya şifre hatalı.'}),
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(loginService: service, onSaved: (_, _) async {}),
        ),
      );

      for (var i = 0; i < 15; i++) {
        await tester.enterText(find.byType(TextFormField).at(0), '210101234');
        await tester.enterText(find.byType(TextFormField).at(1), 'yanlis');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('Çok fazla hatalı giriş'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kStaffLoginDomain).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(kStudentLoginDomain).last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Çok fazla hatalı giriş'), findsNothing);
    },
  );
}
