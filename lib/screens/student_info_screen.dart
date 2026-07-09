import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

typedef StudentLoginCallback =
    Future<void> Function(AuthSession session, bool rememberMe);

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key, required this.onSaved});

  final StudentLoginCallback onSaved;

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  static const _maxFailedAttempts = 15;
  static const _defaultLockoutSeconds = 300;
  static const _tooManyAttemptsMessage =
      'Çok fazla hatalı giriş denemesi yaptınız. Lütfen 5 dakika sonra tekrar deneyin.';

  final _formKey = GlobalKey<FormState>();
  final _authService = const AuthService();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  Timer? _lockoutTimer;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _submitting = false;
  int _failedAttempts = 0;
  int _lockoutRemainingSeconds = 0;
  String? _lockoutMessage;

  bool get _isLockedOut => _lockoutRemainingSeconds > 0;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 18.0 : 24.0;
            final topGap = (constraints.maxHeight * 0.06)
                .clamp(18.0, 46.0)
                .toDouble();

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: topGap),
                      const AppLogo(size: 84),
                      SizedBox(height: constraints.maxHeight < 720 ? 26 : 36),
                      _LoginCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Yoklama Sistemi',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontSize: constraints.maxWidth < 360
                                        ? 24
                                        : 27,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            const _SubtitleDivider(text: 'Öğrenci girişi'),
                            const SizedBox(height: 28),
                            _Field(
                              controller: _numberController,
                              label: 'Öğrenci Numarası',
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.number,
                              validator: _required,
                              enabled: !_submitting && !_isLockedOut,
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              controller: _passwordController,
                              label: 'Şifre',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              validator: _required,
                              enabled: !_submitting && !_isLockedOut,
                              onFieldSubmitted: (_) {
                                if (!_isLockedOut) _submit();
                              },
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Şifreyi göster'
                                    : 'Şifreyi gizle',
                                onPressed: _submitting || _isLockedOut
                                    ? null
                                    : () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            if (_isLockedOut) ...[
                              const SizedBox(height: 18),
                              _LockoutNotice(
                                message:
                                    _lockoutMessage ?? _tooManyAttemptsMessage,
                                remainingSeconds: _lockoutRemainingSeconds,
                              ),
                            ],
                            const SizedBox(height: 18),
                            _RememberMeRow(
                              value: _rememberMe,
                              enabled: !_submitting && !_isLockedOut,
                              onChanged: (value) {
                                setState(() => _rememberMe = value);
                              },
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: 'Giriş Yap',
                              icon: Icons.login_rounded,
                              onPressed: _submit,
                              enabled: !_submitting && !_isLockedOut,
                              loading: _submitting,
                              loadingLabel: 'Giriş yapılıyor...',
                              height: 54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _TrustNote(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunlu';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting || _isLockedOut) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final studentNumber = _numberController.text.trim();
    final password = _passwordController.text;

    try {
      final session = await _authService.login(
        studentNumber: studentNumber,
        password: password,
      );
      await widget.onSaved(session, _rememberMe);
      if (mounted) {
        setState(() {
          _failedAttempts = 0;
          _lockoutMessage = null;
        });
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _handleLoginFailure(error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılamadı: ${error.message}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      _handleLoginFailure(
        AuthException(message: error.toString(), code: 'unknown_error'),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Giriş yapılamadı: $error')));
    }

    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  void _handleLoginFailure(AuthException error) {
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.lineOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textOf(
              context,
            ).withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SubtitleDivider extends StatelessWidget {
  const _SubtitleDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.lineOf(context))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.mutedOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.lineOf(context))),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final bool enabled;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        prefixIconColor: AppColors.brandOf(context),
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

class _TrustNote extends StatelessWidget {
  const _TrustNote();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySoftOf(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_outlined,
            color: AppColors.brandOf(context),
            size: 24,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Giriş bilgileriniz okul sistemiyle doğrulanır.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.mutedOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
