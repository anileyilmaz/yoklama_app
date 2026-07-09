import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/active_session.dart';
import 'package:yoklama_app/models/attendance_record.dart';
import 'package:yoklama_app/models/student.dart';
import 'package:yoklama_app/screens/student_dashboard_screen.dart';

void main() {
  const student = Student(name: 'Test Öğrenci', number: '1212', department: 'Test');

  Widget buildDashboard(List<ActiveSession> activeSessions) {
    return MaterialApp(
      home: StudentDashboardScreen(
        student: student,
        historyFuture: Future.value(const <AttendanceRecord>[]),
        onAttendanceUpdated: () {},
        activeSessions: activeSessions,
      ),
    );
  }

  testWidgets(
    'canlı oturum banner\'ı eklenip kaldırılınca ListView çökmüyor',
    (tester) async {
      await tester.pumpWidget(buildDashboard(const []));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Oturum başladı (socket.io "course:sessionStarted") — banner eklenir.
      await tester.pumpWidget(
        buildDashboard(const [
          ActiveSession(sessionId: 1, courseId: 1, courseName: 'Veri Yapıları'),
        ]),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Veri Yapıları için yoklama açık'), findsOneWidget);

      // İkinci bir ders için de oturum açıldı — birden fazla banner.
      await tester.pumpWidget(
        buildDashboard(const [
          ActiveSession(sessionId: 1, courseId: 1, courseName: 'Veri Yapıları'),
          ActiveSession(sessionId: 2, courseId: 6, courseName: 'Görsel Programlama'),
        ]),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Oturumlardan biri bitti (socket.io "course:sessionEnded") — banner kaldırılır.
      await tester.pumpWidget(
        buildDashboard(const [
          ActiveSession(sessionId: 2, courseId: 6, courseName: 'Görsel Programlama'),
        ]),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Son oturum da bitti — hiç banner kalmadı.
      await tester.pumpWidget(buildDashboard(const []));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
