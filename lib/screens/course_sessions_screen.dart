import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../theme/app_theme.dart';
import '../widgets/attendance_record_tile.dart';
import '../widgets/soft_card.dart';

/// Bir dersin oturum bazlı geçmişi — hangi tarih/saatte katılınıp katılınmadığını
/// gösterir. Veri kaynağı, Dashboard/Geçmiş ile paylaşılan aynı `historyFuture`;
/// burada sadece seçilen derse ait kayıtlarla filtrelenir.
class CourseSessionsScreen extends StatelessWidget {
  const CourseSessionsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.historyFuture,
  });

  final int courseId;
  final String courseName;
  final Future<List<AttendanceRecord>> historyFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseName)),
      body: SafeArea(
        child: FutureBuilder<List<AttendanceRecord>>(
          future: historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SoftCard(
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final records = (snapshot.data ?? const <AttendanceRecord>[])
                .where((record) => record.courseId == courseId)
                .toList();

            if (records.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SoftCard(
                    child: Text(
                      'Bu derse ait oturum kaydı bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    for (final record in records) ...[
                      AttendanceRecordTile(record: record, showLesson: false),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
