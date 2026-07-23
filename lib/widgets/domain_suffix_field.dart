import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kullanıcı adı alanının yanında domain (rol) seçici — Ege SSO giriş ekranının
/// domain açılır listesi referans alınarak tasarlandı (bkz. tasarım dokümanı).
/// `onChanged` null verilirse ya da tek seçenek varsa tek değer sabit/dokunulamaz
/// gösterilir (kayıt ekranındaki kullanım, bkz. register_screen.dart).
class DomainSuffixField extends StatelessWidget {
  const DomainSuffixField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null && options.length > 1;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.lineOf(context)),
      ),
      child: interactive
          ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.mutedOf(context),
                ),
                items: options
                    .map(
                      (domain) => DropdownMenuItem(
                        value: domain,
                        child: Text(
                          domain,
                          style: TextStyle(
                            color: AppColors.textOf(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) onChanged!(selected);
                },
              ),
            )
          : Center(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.mutedOf(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
    );
  }
}
