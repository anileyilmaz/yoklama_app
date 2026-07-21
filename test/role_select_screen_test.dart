import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/screens/role_select_screen.dart';

void main() {
  testWidgets('tapping each role button invokes its callback', (tester) async {
    var studentTapped = false;
    var staffTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RoleSelectScreen(
          onSelectStudent: () => studentTapped = true,
          onSelectStaff: () => staffTapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Öğrenci'));
    await tester.pump();
    expect(studentTapped, isTrue);
    expect(staffTapped, isFalse);

    await tester.tap(find.text('Hoca ve Yönetici'));
    await tester.pump();
    expect(staffTapped, isTrue);
  });
}
