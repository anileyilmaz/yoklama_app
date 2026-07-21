import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SubtitleDivider extends StatelessWidget {
  const SubtitleDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.lineOf(context))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.mutedOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.lineOf(context))),
      ],
    );
  }
}
