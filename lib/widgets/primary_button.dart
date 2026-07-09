import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Uygulama genelinde kullanılan tek düz-renk (gradyansız) birincil buton —
/// web panelinin `button.btn` stiliyle aynı kurumsal lacivert kimliği taşır.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.enabled = true,
    this.loading = false,
    this.loadingLabel = 'Yükleniyor...',
    this.height = 54,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool loading;
  final String loadingLabel;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final active = enabled || loading;
    final onBrand = AppColors.onBrandOf(context);

    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: active ? (loading ? null : onPressed) : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandOf(context),
          disabledBackgroundColor: AppColors.lineOf(context),
          foregroundColor: onBrand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          elevation: active ? 1 : 0,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: onBrand,
                ),
              ),
              const SizedBox(width: 14),
            ] else if (icon != null) ...[
              Icon(icon, color: onBrand, size: 20),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                loading ? loadingLabel : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onBrand,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
