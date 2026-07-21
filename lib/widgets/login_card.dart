import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Giriş/kayıt formlarını saran kart — öğrenci ve hoca/admin girişinde
/// birebir aynı görünüm.
class LoginCard extends StatelessWidget {
  const LoginCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.lineOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textOf(
              context,
            ).withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
