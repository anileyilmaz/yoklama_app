import 'package:flutter/material.dart';

import '../models/staff_user.dart';
import '../services/staff_password_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_row.dart';
import '../widgets/soft_card.dart';
import '../widgets/theme_switch_row.dart';
import 'change_password_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({
    super.key,
    required this.staffUser,
    required this.onLogout,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final StaffUser staffUser;
  final VoidCallback onLogout;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primarySoftOf(context),
              child: Text(
                staffUser.name.isEmpty ? '?' : staffUser.name.characters.first,
                style: TextStyle(
                  color: AppColors.brandOf(context),
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              staffUser.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              staffUser.role == 'teacher' ? 'Öğretim Üyesi' : staffUser.role,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            if (staffUser.facultyName != null) ...[
              const SizedBox(height: 4),
              Text(
                staffUser.facultyName!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ProfileRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Şifre Değiştir',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen(
                          passwordChanger: const StaffPasswordService(),
                        ),
                      ),
                    ),
                  ),
                  ThemeSwitchRow(enabled: darkMode, onChanged: onDarkModeChanged),
                  ProfileRow(
                    icon: Icons.logout_rounded,
                    title: 'Çıkış Yap',
                    danger: true,
                    onTap: onLogout,
                    showLine: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
