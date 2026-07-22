import 'package:flutter/material.dart';

import '../models/staff_auth_session.dart';
import '../services/staff_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/login_card.dart';
import '../widgets/login_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/subtitle_divider.dart';

typedef StaffLoginCallback = Future<void> Function(StaffAuthSession session);

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({
    super.key,
    required this.onSaved,
    this.authService = const StaffAuthService(),
  });

  final StaffLoginCallback onSaved;
  final StaffAuthService authService;

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final session = await widget.authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (session.staffUser.role != 'teacher') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yönetici paneli mobil uygulamada yakında.'),
          ),
        );
        return;
      }
      await widget.onSaved(session);
    } on StaffAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılamadı: ${error.message}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Giriş yapılamadı: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 84),
                    const SizedBox(height: 32),
                    LoginCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Yoklama Sistemi',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 18),
                          const SubtitleDivider(text: 'Hoca / Yönetici girişi'),
                          const SizedBox(height: 28),
                          LoginField(
                            controller: _usernameController,
                            label: 'Kullanıcı Adı',
                            icon: Icons.person_outline_rounded,
                            validator: _required,
                            enabled: !_submitting,
                          ),
                          const SizedBox(height: 14),
                          LoginField(
                            controller: _passwordController,
                            label: 'Şifre',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: _required,
                            enabled: !_submitting,
                            onFieldSubmitted: (_) => _submit(),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Şifreyi göster'
                                  : 'Şifreyi gizle',
                              onPressed: _submitting
                                  ? null
                                  : () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Giriş Yap',
                            icon: Icons.login_rounded,
                            onPressed: _submit,
                            enabled: !_submitting,
                            loading: _submitting,
                            loadingLabel: 'Giriş yapılıyor...',
                            height: 54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
