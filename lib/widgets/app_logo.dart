import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fact_check_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}
