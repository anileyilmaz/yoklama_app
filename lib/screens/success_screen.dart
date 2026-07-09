import 'package:flutter/material.dart';

import '../models/attendance_result.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/soft_card.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.result});

  final AttendanceResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: CustomPaint(painter: _ConfettiPainter()),
                  ),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.primary],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                result.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
              const SizedBox(height: 34),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ders Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Ders', value: result.lesson),
                    _InfoRow(label: 'Tarih', value: result.date),
                    _InfoRow(
                      label: 'Saat',
                      value: result.time,
                      showLine: false,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Ana Sayfaya Don',
                icon: Icons.home_outlined,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showLine = true,
  });

  final String label;
  final String value;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: showLine
            ? Border(bottom: BorderSide(color: AppColors.lineOf(context)))
            : null,
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: AppColors.mutedOf(context))),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppColors.primary, AppColors.accent, AppColors.amber];
    final offsets = [
      const Offset(10, 24),
      const Offset(36, 10),
      const Offset(102, 22),
      const Offset(118, 66),
      const Offset(24, 98),
      const Offset(92, 112),
    ];

    for (var i = 0; i < offsets.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: offsets[i], width: 7, height: 7),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
