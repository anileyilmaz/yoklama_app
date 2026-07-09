import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled || loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              )
            : null,
        color: active ? null : AppColors.lineOf(context),
        borderRadius: BorderRadius.circular(8),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled && !loading ? onPressed : null,
          child: SizedBox(
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Flexible(
                  child: Text(
                    loading ? 'Giris yapiliyor...' : label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!loading) ...[
                  const SizedBox(width: 18),
                  Icon(icon, color: Colors.white, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
