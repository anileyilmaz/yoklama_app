import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_button.dart';
import '../widgets/qr_art.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const QrWelcomeArt(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                child: Column(
                  children: [
                    const AppLogo(size: 62),
                    const SizedBox(height: 22),
                    Text(
                      'Yoklama',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Akilli Yoklama Sistemi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.mutedOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ogrenci bilgilerini gir, tahtadaki QR kodu okut ve yoklamani tamamla.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    GradientButton(label: 'Baslayalim', onPressed: onStart),
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
