import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
              child: Column(
                children: [
                  const AppLogo(size: 68, onSurface: true),
                  const SizedBox(height: 18),
                  Text(
                    'Yoklama',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Akıllı Yoklama Sistemi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  children: [
                    Text(
                      'Öğrenci bilgilerini gir, tahtadaki QR kodu okut ve yoklamanı tamamla.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(label: 'Başlayalım', onPressed: onStart),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
