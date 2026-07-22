import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/models/enroll_request.dart';
import 'package:yoklama_app/models/live_attendance_entry.dart';
import 'package:yoklama_app/screens/live_session_screen.dart';

void main() {
  Widget buildBody({
    String? qrPayload,
    List<LiveAttendanceEntry> attendees = const [],
    List<EnrollRequest> pendingRequests = const [],
    Future<void> Function(String studentNumber)? onAddManual,
  }) {
    return MaterialApp(
      home: LiveSessionBody(
        courseName: 'Veri Yapıları',
        qrPayload: qrPayload,
        attendees: attendees,
        pendingRequests: pendingRequests,
        onApprove: (_) {},
        onReject: (_) {},
        onEnd: () {},
        onAddManual: onAddManual ?? (_) async {},
      ),
    );
  }

  testWidgets('renders course name and attendee count', (tester) async {
    await tester.pumpWidget(
      buildBody(
        qrPayload: 'YOKLAMA|1|abc',
        attendees: const [
          LiveAttendanceEntry(
            name: 'Ali Veli',
            studentNumber: '1',
            department: 'X',
            createdAt: '10:00',
            manual: false,
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Veri Yapıları'), findsOneWidget);
    expect(find.text('Ali Veli'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding/removing pending requests does not crash', (
    tester,
  ) async {
    await tester.pumpWidget(buildBody());
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      buildBody(
        pendingRequests: const [
          EnrollRequest(
            id: 1,
            name: 'Ayşe Yılmaz',
            studentNumber: '2',
            department: 'Y',
          ),
        ],
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);

    await tester.pumpWidget(buildBody());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tapping öğrenci ekle opens a dialog and submits the entered number',
    (tester) async {
      String? submittedNumber;
      await tester.pumpWidget(
        buildBody(
          onAddManual: (studentNumber) async {
            submittedNumber = studentNumber;
          },
        ),
      );

      // pumpAndSettle burada kullanılmıyor: dialog'daki TextField autofocus
      // olduğundan yanıp sönen imleç animasyonu sonsuza dek tekrarlanıyor,
      // pumpAndSettle bu yüzden hiç "durulmuyor" ve timeout'a düşüyor —
      // bilinen bir Flutter test tuzağı, bunun yerine sabit pump'lar kullanılır.
      await tester.tap(find.byTooltip('Öğrenci ekle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Öğrenci Numarası'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '210101234');
      await tester.tap(find.text('Ekle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submittedNumber, '210101234');
      expect(find.text('Öğrenci ekle'), findsNothing);
    },
  );

  testWidgets(
    'shows an inline error and keeps the dialog open when onAddManual throws',
    (tester) async {
      await tester.pumpWidget(
        buildBody(
          onAddManual: (_) async {
            throw Exception('Bu numarayla kayıtlı öğrenci bulunamadı.');
          },
        ),
      );

      await tester.tap(find.byTooltip('Öğrenci ekle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), '999999');
      await tester.tap(find.text('Ekle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.textContaining('Bu numarayla kayıtlı öğrenci bulunamadı'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'attempting to leave via the back button shows a confirmation and ends the session if confirmed',
    (tester) async {
      var endCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LiveSessionBody(
                    courseName: 'Veri Yapıları',
                    qrPayload: null,
                    attendees: const [],
                    pendingRequests: const [],
                    onApprove: (_) {},
                    onReject: (_) {},
                    onEnd: () => endCalled = true,
                    onAddManual: (_) async {},
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Geri tuşu oturumu doğrudan kapatmamalı — hâlâ canlı oturum ekranındayız.
      expect(find.text('Veri Yapıları'), findsOneWidget);
      expect(find.textContaining('sona erecek'), findsOneWidget);
      expect(endCalled, isFalse);

      await tester.tap(find.text('Bitir ve çık'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(endCalled, isTrue);
    },
  );

  testWidgets(
    'cancelling the leave confirmation keeps the session screen open',
    (tester) async {
      var endCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LiveSessionBody(
                    courseName: 'Veri Yapıları',
                    qrPayload: null,
                    attendees: const [],
                    pendingRequests: const [],
                    onApprove: (_) {},
                    onReject: (_) {},
                    onEnd: () => endCalled = true,
                    onAddManual: (_) async {},
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Vazgeç'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(endCalled, isFalse);
      expect(find.text('Veri Yapıları'), findsOneWidget);
    },
  );
}
