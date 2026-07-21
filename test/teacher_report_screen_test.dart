import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/teacher_course.dart';
import 'package:yoklama_app/screens/teacher_report_screen.dart';

void main() {
  testWidgets('renders the course dropdown', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherReportScreen(
          coursesFuture: Future.value(const [
            TeacherCourse(id: 1, name: 'Veri Yapıları', enrolled: 42),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ders'), findsOneWidget);
  });
}
