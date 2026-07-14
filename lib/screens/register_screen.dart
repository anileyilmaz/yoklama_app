import 'package:flutter/material.dart';

import '../services/register_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/soft_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registerService = const RegisterService();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: _submitted ? _buildPendingNotice(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 380 ? 18.0 : 24.0;
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Column(
              children: [
                const AppLogo(size: 68),
                const SizedBox(height: 24),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Öğrenci kaydı',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bilgilerini gönderdikten sonra yönetici onayı beklenecek.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.mutedOf(context)),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_submitting,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _numberController,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Öğrenci Numarası',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _departmentController,
                        enabled: !_submitting,
                        decoration: const InputDecoration(
                          labelText: 'Bölüm',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_submitting,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre (en az 6 karakter)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_submitting,
                        obscureText: _obscureConfirmPassword,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Şifre (tekrar)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Kayıt Ol',
                        icon: Icons.how_to_reg_outlined,
                        onPressed: _submit,
                        enabled: !_submitting,
                        loading: _submitting,
                        loadingLabel: 'Gönderiliyor...',
                        height: 54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Kaydınız alındı',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Yönetici onayından sonra bu öğrenci numarası ve şifreyle giriş yapabileceksiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedOf(context)),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Girişe Dön',
            icon: Icons.login_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await _registerService.register(
        name: _nameController.text,
        studentNumber: _numberController.text,
        department: _departmentController.text,
        password: _passwordController.text,
      );
      if (mounted) setState(() => _submitted = true);
    } on RegisterException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }

    if (mounted) setState(() => _submitting = false);
  }
}
