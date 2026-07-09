import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QrWelcomeArt extends StatelessWidget {
  const QrWelcomeArt({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 255,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 178,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.accent],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(110),
                bottomRight: Radius.circular(110),
              ),
            ),
          ),
          Positioned(
            top: 42,
            child: Container(
              width: 156,
              height: 122,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lineOf(context), width: 5),
              ),
              child: CustomPaint(painter: MiniQrPainter()),
            ),
          ),
          Positioned(
            left: 56,
            bottom: 22,
            child: Icon(
              Icons.backpack_rounded,
              color: AppColors.primaryDark,
              size: 58,
            ),
          ),
          Positioned(
            right: 70,
            bottom: 64,
            child: Container(
              width: 30,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.dark;
    final accent = Paint()..color = AppColors.primary;
    final cell = size.width / 9;
    final blocks = <Offset>[
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(2, 0),
      const Offset(0, 1),
      const Offset(2, 1),
      const Offset(0, 2),
      const Offset(1, 2),
      const Offset(2, 2),
      const Offset(6, 0),
      const Offset(7, 0),
      const Offset(8, 0),
      const Offset(6, 1),
      const Offset(8, 1),
      const Offset(6, 2),
      const Offset(7, 2),
      const Offset(8, 2),
      const Offset(0, 6),
      const Offset(1, 6),
      const Offset(2, 6),
      const Offset(0, 7),
      const Offset(2, 7),
      const Offset(0, 8),
      const Offset(1, 8),
      const Offset(2, 8),
      const Offset(4, 1),
      const Offset(4, 3),
      const Offset(5, 4),
      const Offset(7, 4),
      const Offset(3, 5),
      const Offset(5, 6),
      const Offset(6, 7),
      const Offset(8, 8),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            block.dx * cell,
            block.dy * cell,
            cell * 0.78,
            cell * 0.78,
          ),
          const Radius.circular(1.5),
        ),
        block.dx == 5 || block.dy == 5 ? accent : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
