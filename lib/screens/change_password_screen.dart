import 'package:flutter/material.dart';

import '../services/password_changer.dart';
import '../services/password_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    this.passwordChanger = const PasswordService(),
  });

  final PasswordChanger passwordChanger;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await widget.passwordChanger.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
      );
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Değiştir')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Bu alan zorunlu' : null,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureCurrent = !_obscureCurrent,
                    ),
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Bu alan zorunlu';
                  if (value.length < 6) return 'En az 6 karakter olmalı';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value != _newController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  prefixIcon: Icon(Icons.lock_reset_rounded),
                ),
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Şifreyi Güncelle',
                icon: Icons.check_rounded,
                onPressed: _submit,
                loading: _submitting,
                loadingLabel: 'Güncelleniyor...',
              ),
              const SizedBox(height: 16),
              Text(
                'Şifreni değiştirdikten sonra diğer cihazlardaki oturumların sonlanır.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
