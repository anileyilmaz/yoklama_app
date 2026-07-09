import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yoklama_app/main.dart';
import 'package:yoklama_app/models/attendance_session.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows welcome screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendanceApp());
    await tester.pumpAndSettle();

    expect(find.text('Yoklama'), findsOneWidget);
    expect(find.text('Baslayalim'), findsOneWidget);
  });

  test('parses plain QR session code', () {
    final session = AttendanceSession.fromQr('MAT101-2026-01');

    expect(session.sessionCode, 'MAT101-2026-01');
  });

  test('parses JSON QR payload', () {
    final session = AttendanceSession.fromQr(
      '{"sessionCode":"ABC123","lesson":"Mobil Programlama","teacher":"Hoca"}',
    );

    expect(session.sessionCode, 'ABC123');
    expect(session.lesson, 'Mobil Programlama');
    expect(session.teacher, 'Hoca');
  });
}
