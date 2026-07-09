import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lineOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textOf(
              context,
            ).withValues(alpha: AppColors.isDark(context) ? 0.14 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
