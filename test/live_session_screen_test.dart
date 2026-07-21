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
}
