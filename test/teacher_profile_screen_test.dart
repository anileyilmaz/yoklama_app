import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/staff_user.dart';
import 'package:yoklama_app/screens/teacher_profile_screen.dart';

void main() {
  const staffUser = StaffUser(
    username: 'hoca1',
    name: 'Ayşe Hoca',
    role: 'teacher',
    facultyId: 3,
    facultyName: 'Mühendislik Fakültesi',
  );

  testWidgets('renders name and faculty, logout invokes callback', (
    tester,
  ) async {
    var loggedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TeacherProfileScreen(
          staffUser: staffUser,
          onLogout: () => loggedOut = true,
          darkMode: false,
          onDarkModeChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Ayşe Hoca'), findsOneWidget);
    expect(find.text('Mühendislik Fakültesi'), findsOneWidget);

    await tester.tap(find.text('Çıkış Yap'));
    await tester.pump();
    expect(loggedOut, isTrue);
  });
}
