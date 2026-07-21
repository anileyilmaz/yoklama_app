import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ThemeSwitchRow extends StatelessWidget {
  const ThemeSwitchRow({super.key, required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lineOf(context))),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined,
            size: 21,
            color: AppColors.textOf(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Koyu Mod',
              style: TextStyle(
                color: AppColors.textOf(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppColors.brandOf(context),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
