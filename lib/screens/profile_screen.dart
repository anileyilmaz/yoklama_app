import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.student,
    required this.onLogout,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final Student student;
  final VoidCallback onLogout;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = const ProfileService();
  late Future<Student> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.fetchProfile(fallback: widget.student);
  }

  void _reload() {
    setState(() {
      _profileFuture = _profileService.fetchProfile(fallback: widget.student);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Student>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final student = snapshot.data ?? widget.student;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const LinearProgressIndicator(minHeight: 2),
                  if (snapshot.hasError) ...[
                    _ProfileError(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    ),
                    const SizedBox(height: 16),
                  ],
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primarySoftOf(context),
                    child: Text(
                      student.name.isEmpty
                          ? '?'
                          : student.name.characters.first,
                      style: TextStyle(
                        color: AppColors.brandOf(context),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.number,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.department,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedOf(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileRow(
                          icon: Icons.person_outline_rounded,
                          title: 'Bilgilerim',
                          onTap: () => _showStudentInfo(context, student),
                        ),
                        _ProfileRow(
                          icon: Icons.lock_outline_rounded,
                          title: 'Şifre Değiştir',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          ),
                        ),
                        _ThemeSwitchRow(
                          enabled: widget.darkMode,
                          onChanged: widget.onDarkModeChanged,
                        ),
                        const _SwitchRow(),
                        _ProfileRow(
                          icon: Icons.logout_rounded,
                          title: 'Çıkış Yap',
                          danger: true,
                          onTap: widget.onLogout,
                          showLine: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStudentInfo(BuildContext context, Student student) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilgilerim',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                _InfoLine(label: 'Ad Soyad', value: student.name),
                _InfoLine(label: 'Öğrenci Numarası', value: student.number),
                _InfoLine(
                  label: 'Bölüm',
                  value: student.department,
                  showLine: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.showLine = true,
  });

  final String label;
  final String value;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: showLine
            ? Border(bottom: BorderSide(color: AppColors.lineOf(context)))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
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

class _ThemeSwitchRow extends StatelessWidget {
  const _ThemeSwitchRow({required this.enabled, required this.onChanged});

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

class _SwitchRow extends StatefulWidget {
  const _SwitchRow();

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  bool _enabled = true;

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
            Icons.notifications_none_rounded,
            size: 21,
            color: AppColors.textOf(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bildirimler',
              style: TextStyle(
                color: AppColors.textOf(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: _enabled,
            activeThumbColor: AppColors.brandOf(context),
            onChanged: (value) => setState(() => _enabled = value),
          ),
        ],
      ),
    );
  }
}
