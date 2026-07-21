import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/teaching_session_summary.dart';
import 'package:yoklama_app/screens/teacher_session_history_screen.dart';

void main() {
  testWidgets('renders session course names', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherSessionHistoryScreen(
          historyFuture: Future.value(const [
            TeachingSessionSummary(
              id: 1,
              courseName: 'Veri Yapıları',
              createdAt: '2026-07-20 10:00:00',
              endedAt: '2026-07-20 10:50:00',
              gps: false,
              count: 12,
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Veri Yapıları'), findsOneWidget);
  });

  testWidgets('shows empty state with no sessions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherSessionHistoryScreen(
          historyFuture: Future.value(const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz bir yoklama oturumu başlatmadınız.'), findsOneWidget);
  });
}
