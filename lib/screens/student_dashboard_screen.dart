import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/soft_card.dart';
import 'qr_scan_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key, required this.student});

  final Student student;

  static const _recentRecords = [
    AttendanceRecord(
      lesson: 'Veri Yapilari',
      date: '07.07.2025',
      time: '13:30',
      joined: true,
    ),
    AttendanceRecord(
      lesson: 'Web Programlama',
      date: '04.07.2025',
      time: '10:15',
      joined: true,
    ),
    AttendanceRecord(
      lesson: 'Veritabani',
      date: '01.07.2025',
      time: '09:00',
      joined: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final nameParts = student.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isEmpty ? student.name : nameParts.first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              'Merhaba, ${firstName.isNotEmpty ? firstName : student.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${student.department} - ${student.number}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 24),
            const _AttendanceStatusCard(),
            const SizedBox(height: 28),
            SizedBox(
              height: 62,
              child: GradientButton(
                label: 'QR ile Yoklama Ver',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QrScanScreen(student: student),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Yoklamalar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_recentRecords.where((record) => record.joined).length}/${_recentRecords.length} katilim',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final record in _recentRecords) ...[
              _RecentAttendanceTile(record: record),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mintOf(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yoklama Durumu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Bugun aktif bir ders yoklamasi bekleniyor.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.amberSoftOf(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Hazir',
              style: TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentAttendanceTile extends StatelessWidget {
  const _RecentAttendanceTile({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.joined ? AppColors.primary : AppColors.danger;
    final statusBg = record.joined
        ? AppColors.mintOf(context)
        : AppColors.dangerSoftOf(context);

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              record.joined
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: statusColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.lesson,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.date} - ${record.time}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            record.joined ? 'Katildin' : 'Kacirdi',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
