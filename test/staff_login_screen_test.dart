import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/screens/staff_login_screen.dart';

void main() {
  testWidgets('renders username and password fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StaffLoginScreen(onSaved: (_) async {})),
    );

    expect(find.text('Kullanıcı Adı'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
