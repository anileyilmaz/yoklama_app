import 'dart:async';

import 'package:flutter/material.dart';

import '../models/unified_login_result.dart';
import '../services/unified_login_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/domain_suffix_field.dart';
import '../widgets/login_card.dart';
import '../widgets/login_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/subtitle_divider.dart';
import 'register_screen.dart';

typedef UnifiedLoginCallback =
    Future<void> Function(UnifiedLoginResult result, bool rememberMe);

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSaved,
    this.loginService = const UnifiedLoginService(),
  });

  final UnifiedLoginCallback onSaved;
  final UnifiedLoginService loginService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _maxFailedAttempts = 15;
  static const _defaultLockoutSeconds = 300;
  static const _tooManyAttemptsMessage =
      'Çok fazla hatalı giriş denemesi yaptınız. Lütfen 5 dakika sonra tekrar deneyin.';

  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _passwordController = TextEditingController();

  String _domain = kStudentLoginDomain;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _submitting = false;
  Timer? _lockoutTimer;
  int _failedAttempts = 0;
  int _lockoutRemainingSeconds = 0;
  String? _lockoutMessage;

  bool get _isStudentMode => _domain == kStudentLoginDomain;
  bool get _isLockedOut => _lockoutRemainingSeconds > 0;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _valueController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onDomainChanged(String domain) {
    _lockoutTimer?.cancel();
    setState(() {
      _domain = domain;
      _failedAttempts = 0;
      _lockoutRemainingSeconds = 0;
      _lockoutMessage = null;
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null;
  }

  Future<void> _submit() async {
    final locked = _isStudentMode && _isLockedOut;
    if (_submitting || locked) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final result = await widget.loginService.login(
        value: _valueController.text.trim(),
        domain: _domain,
        password: _passwordController.text,
      );

      if (result is StaffLoginResult && result.session.staffUser.role != 'teacher') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yönetici paneli mobil uygulamada yakında.'),
            ),
          );
          setState(() => _submitting = false);
        }
        return;
      }

      await widget.onSaved(result, _rememberMe);
      if (mounted) {
        setState(() {
          _failedAttempts = 0;
          _lockoutMessage = null;
        });
      }
    } on UnifiedLoginException catch (error) {
      if (!mounted) return;
      if (_isStudentMode) _handleLoginFailure(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılamadı: ${error.message}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      if (_isStudentMode) {
        _handleLoginFailure(
          UnifiedLoginException(
            message: error.toString(),
            code: 'unknown_error',
          ),
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Giriş yapılamadı: $error')));
    }

    if (mounted) setState(() => _submitting = false);
  }

  void _handleLoginFailure(UnifiedLoginException error) {
    final isBackendLockout = error.code == 'too_many_attempts';
    final nextFailedAttempts = _failedAttempts + 1;

    if (isBackendLockout || nextFailedAttempts >= _maxFailedAttempts) {
      _startLockout(
        retryAfterSeconds: error.retryAfterSeconds ?? _defaultLockoutSeconds,
        message: isBackendLockout ? error.message : _tooManyAttemptsMessage,
      );
      return;
    }

    setState(() => _failedAttempts = nextFailedAttempts);
  }

  void _startLockout({
    required int retryAfterSeconds,
    required String message,
  }) {
    _lockoutTimer?.cancel();
    setState(() {
      _failedAttempts = _maxFailedAttempts;
      _lockoutMessage = message;
      _lockoutRemainingSeconds = retryAfterSeconds;
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutRemainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _failedAttempts = 0;
          _lockoutRemainingSeconds = 0;
          _lockoutMessage = null;
        });
        return;
      }
      setState(() => _lockoutRemainingSeconds--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locked = _isStudentMode && _isLockedOut;
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: SafeArea(
        child: LayoutBuilder(
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
                    const SizedBox(height: 24),
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
                          SubtitleDivider(
                            text: _isStudentMode
                                ? 'Öğrenci girişi'
                                : 'Hoca / Yönetici girişi',
                          ),
                          const SizedBox(height: 28),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: LoginField(
                                  controller: _valueController,
                                  label: 'Kullanıcı adınız',
                                  icon: Icons.person_outline_rounded,
                                  keyboardType: _isStudentMode
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  validator: _required,
                                  enabled: !_submitting && !locked,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: DomainSuffixField(
                                  value: _domain,
                                  options: const [
                                    kStaffLoginDomain,
                                    kStudentLoginDomain,
                                  ],
                                  // Kilitliyken bile domain seçici etkin kalmalı:
                                  // kilidi aşmanın tek yolu farklı bir domaine
                                  // geçip (ki bu sayacı sıfırlar) geri dönmek.
                                  enabled: !_submitting,
                                  onChanged: _onDomainChanged,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LoginField(
                            controller: _passwordController,
                            label: 'Şifre',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: _required,
                            enabled: !_submitting && !locked,
                            onFieldSubmitted: (_) {
                              if (!locked) _submit();
                            },
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Şifreyi göster'
                                  : 'Şifreyi gizle',
                              onPressed: _submitting || locked
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
                          if (_isStudentMode && _isLockedOut) ...[
                            const SizedBox(height: 18),
                            _LockoutNotice(
                              message:
                                  _lockoutMessage ?? _tooManyAttemptsMessage,
                              remainingSeconds: _lockoutRemainingSeconds,
                            ),
                          ],
                          if (_isStudentMode) ...[
                            const SizedBox(height: 18),
                            _RememberMeRow(
                              value: _rememberMe,
                              enabled: !_submitting && !locked,
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Giriş Yap',
                            icon: Icons.login_rounded,
                            onPressed: _submit,
                            enabled: !_submitting && !locked,
                            loading: _submitting,
                            loadingLabel: 'Giriş yapılıyor...',
                            height: 54,
                          ),
                          if (_isStudentMode) ...[
                            const SizedBox(height: 18),
                            TextButton(
                              onPressed: _submitting || locked
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                              child: const Text('Hesabın yok mu? Kayıt ol'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LockoutNotice extends StatelessWidget {
  const _LockoutNotice({required this.message, required this.remainingSeconds});

  final String message;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoftOf(context),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textOf(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$minutes:$seconds',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: enabled
                ? (checked) => onChanged(checked ?? false)
                : null,
            activeColor: AppColors.brandOf(context),
            checkColor: AppColors.onBrandOf(context),
            side: BorderSide(color: AppColors.brandOf(context), width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Beni hatırla',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
