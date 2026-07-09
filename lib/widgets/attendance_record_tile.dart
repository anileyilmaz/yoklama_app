import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../theme/app_theme.dart';
import 'soft_card.dart';

/// Geçmiş Yoklamalar ve ders detayı ekranlarında ortak kullanılan tek oturum
/// satırı — [showLesson] ders adı zaten ekran başlığından belliyse (ör. ders
/// detayı) gizlenebilir.
class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({
    super.key,
    required this.record,
    this.showLesson = true,
  });

  final AttendanceRecord record;
  final bool showLesson;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.joined
        ? AppColors.brandOf(context)
        : AppColors.danger;
    final statusBg = record.joined
        ? AppColors.primarySoftOf(context)
        : AppColors.dangerSoftOf(context);

    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Icon(
              record.joined
                  ? Icons.event_available_outlined
                  : Icons.event_busy_outlined,
              color: statusColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLesson) ...[
                  Text(
                    record.lesson,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${record.date} - ${record.time}',
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
              color: statusBg,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Row(
              children: [
                Icon(
                  record.joined ? Icons.check_rounded : Icons.close_rounded,
                  color: statusColor,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  record.joined ? 'Katıldım' : 'Katılmadım',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
