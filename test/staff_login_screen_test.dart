import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:yoklama_app/screens/staff_login_screen.dart';
import 'package:yoklama_app/services/staff_auth_service.dart';

void main() {
  testWidgets('renders username and password fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StaffLoginScreen(onSaved: (_) async {})),
    );

    expect(find.text('Kullanıcı Adı'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });

  testWidgets(
    'admin login succeeds against backend but is blocked from entering the '
    'app, and does not call onSaved',
    (tester) async {
      var onSavedCalled = false;
      final authService = StaffAuthService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'token': 'fake-token',
              'role': 'admin',
              'name': 'Test Admin',
            }),
            200,
          );
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StaffLoginScreen(
            authService: authService,
            onSaved: (_) async {
              onSavedCalled = true;
            },
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));
      await tester.enterText(fields.at(0), 'admin');
      await tester.enterText(fields.at(1), 'admin123');

      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      expect(onSavedCalled, isFalse);
      expect(
        find.text('Yönetici paneli mobil uygulamada yakında.'),
        findsOneWidget,
      );
    },
  );
}
