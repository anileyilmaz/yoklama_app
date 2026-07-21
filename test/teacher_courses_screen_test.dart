import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/teacher_course.dart';
import 'package:yoklama_app/screens/teacher_courses_screen.dart';

void main() {
  testWidgets('renders course names from the future', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherCoursesScreen(
          coursesFuture: Future.value(const [
            TeacherCourse(id: 1, name: 'Veri Yapıları', enrolled: 42),
            TeacherCourse(id: 2, name: 'Algoritmalar', enrolled: 30),
          ]),
          onSessionStarted: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Veri Yapıları'), findsOneWidget);
    expect(find.text('Algoritmalar'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no courses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherCoursesScreen(
          coursesFuture: Future.value(const []),
          onSessionStarted: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Henüz size tanımlı bir ders bulunmuyor.'),
      findsOneWidget,
    );
  });
}
