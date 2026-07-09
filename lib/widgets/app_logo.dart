import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.onSurface = false});

  final double size;

  /// true iken lacivert bir zemin üzerine (ör. header şeridi) çizilir —
  /// web panelinin `.topbar .brand .mark` rozetiyle aynı yarı saydam beyaz stil.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onSurface
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.brandOf(context),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(
        Icons.fact_check_rounded,
        color: onSurface ? Colors.white : AppColors.onBrandOf(context),
        size: size * 0.52,
      ),
    );
  }
}
