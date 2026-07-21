import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.danger = false,
    this.showLine = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool danger;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textOf(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showLine
              ? Border(bottom: BorderSide(color: AppColors.lineOf(context)))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}
