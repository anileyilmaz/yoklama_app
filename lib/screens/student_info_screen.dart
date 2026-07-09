import 'package:flutter/material.dart';

import '../models/student.dart';
import '../theme/app_theme.dart';

typedef StudentLoginCallback =
    Future<void> Function(Student student, bool rememberMe);

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key, required this.onSaved});

  final StudentLoginCallback onSaved;

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _submitting = false;

  @override
  void dispose() {
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 380
                    ? 18.0
                    : 24.0;
                final topGap = (constraints.maxHeight * 0.07)
                    .clamp(22.0, 58.0)
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
                          const _LogoMark(),
                          SizedBox(
                            height: constraints.maxHeight < 720 ? 34 : 46,
                          ),
                          _LoginCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Yoklama Sistemi',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkText
                                            : const Color(0xff07351f),
                                        fontSize: constraints.maxWidth < 360
                                            ? 27
                                            : 32,
                                        height: 1.05,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                const _SubtitleDivider(text: 'Öğrenci girişi'),
                                const SizedBox(height: 30),
                                _Field(
                                  controller: _numberController,
                                  label: 'Öğrenci Numarası',
                                  icon: Icons.person_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: _required,
                                  enabled: !_submitting,
                                ),
                                const SizedBox(height: 14),
                                _Field(
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
                                const SizedBox(height: 18),
                                _RememberMeRow(
                                  value: _rememberMe,
                                  enabled: !_submitting,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value);
                                  },
                                ),
                                const SizedBox(height: 28),
                                _LoginButton(
                                  label: 'Giriş Yap',
                                  onPressed: _submit,
                                  enabled: !_submitting,
                                  loading: _submitting,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          const _TrustNote(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final studentNumber = _numberController.text.trim();
    await widget.onSaved(
      Student(
        name: 'Demo Ogrenci',
        number: studentNumber,
        department: 'Bilgisayar Muhendisligi',
      ),
      _rememberMe,
    );

    if (mounted) {
      setState(() => _submitting = false);
    }
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.cardOf(
          context,
        ).withValues(alpha: isDark ? 0.94 : 0.98),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: 128,
      height: 128,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context).withValues(alpha: isDark ? 0.9 : 0.96),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.13),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrMarkPainter(
          color: isDark ? AppColors.accent : AppColors.primary,
        ),
      ),
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
        const Expanded(child: _SoftLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.mutedOf(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: _SoftLine()),
      ],
    );
  }
}

class _SoftLine extends StatelessWidget {
  const _SoftLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0),
            AppColors.primary.withValues(alpha: 0.34),
            AppColors.primary.withValues(alpha: 0),
          ],
        ),
      ),
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
    final isDark = AppColors.isDark(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color: AppColors.textOf(context),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.mutedOf(context),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.mutedOf(context),
        filled: true,
        fillColor: isDark
            ? const Color(0xff17232d)
            : Colors.white.withValues(alpha: 0.88),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.lineOf(context), width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.lineOf(context), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.accent : AppColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
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
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: enabled
                ? (checked) => onChanged(checked ?? false)
                : null,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: BorderSide(color: AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Beni hatırla',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textOf(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
    required this.loading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled || loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff07924f), Color(0xff2fc36f)],
              )
            : null,
        color: active ? null : AppColors.lineOf(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 11),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled && !loading ? onPressed : null,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                ] else ...[
                  const Icon(
                    Icons.login_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                ],
                Flexible(
                  child: Text(
                    loading ? 'Giriş yapılıyor...' : label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.mintOf(context).withValues(alpha: 0.72),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
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

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return ColoredBox(
      color: AppColors.surfaceOf(context),
      child: CustomPaint(painter: _LoginBackgroundPainter(isDark: isDark)),
    );
  }
}

class _QrMarkPainter extends CustomPainter {
  const _QrMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    final corner = size.width * 0.26;
    final inset = size.width * 0.02;

    canvas.drawLine(Offset(inset, corner), Offset(inset, inset), paint);
    canvas.drawLine(Offset(inset, inset), Offset(corner, inset), paint);
    canvas.drawLine(
      Offset(size.width - corner, inset),
      Offset(size.width - inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, corner),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - corner),
      Offset(inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(corner, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - corner, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - corner),
      paint,
    );

    final fill = Paint()..color = color;
    final cell = size.width / 9;
    final blocks = <Offset>[
      const Offset(2, 2),
      const Offset(3, 2),
      const Offset(2, 3),
      const Offset(3, 3),
      const Offset(6, 2),
      const Offset(7, 2),
      const Offset(6, 3),
      const Offset(7, 3),
      const Offset(2, 6),
      const Offset(3, 6),
      const Offset(2, 7),
      const Offset(3, 7),
      const Offset(5, 4),
      const Offset(4, 5),
      const Offset(6, 5),
      const Offset(5, 6),
      const Offset(7, 6),
      const Offset(6, 7),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            block.dx * cell,
            block.dy * cell,
            cell * 0.72,
            cell * 0.72,
          ),
          const Radius.circular(2),
        ),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final primary = isDark ? AppColors.accent : AppColors.primary;
    final linePaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.08 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final softFill = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.07 : 0.08)
      ..style = PaintingStyle.fill;

    final halo = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primary.withValues(alpha: isDark ? 0.16 : 0.1),
              primary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.52, size.height * 0.2),
              radius: size.width * 0.42,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.2),
      size.width * 0.42,
      halo,
    );

    final hill = Path()
      ..moveTo(0, size.height * 0.29)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.24,
        size.width,
        size.height * 0.31,
      )
      ..lineTo(size.width, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.36,
        0,
        size.height * 0.4,
      )
      ..close();
    canvas.drawPath(hill, softFill);

    _drawSchool(canvas, size, linePaint);
    _drawTrees(canvas, size, softFill);
    _drawDots(canvas, Offset(size.width * 0.14, size.height * 0.34), primary);
    _drawDots(canvas, Offset(size.width * 0.84, size.height * 0.1), primary);
    _drawBottomWaves(canvas, size, primary);
  }

  void _drawSchool(Canvas canvas, Size size, Paint paint) {
    final left = size.width * 0.08;
    final top = size.height * 0.14;
    final width = size.width * 0.25;
    final height = size.height * 0.12;

    final roof = Path()
      ..moveTo(left, top + height * 0.34)
      ..lineTo(left + width * 0.5, top)
      ..lineTo(left + width, top + height * 0.34);
    canvas.drawPath(roof, paint);
    canvas.drawRect(
      Rect.fromLTWH(
        left + width * 0.12,
        top + height * 0.34,
        width * 0.76,
        height * 0.5,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(left + width * 0.5, top),
      Offset(left + width * 0.5, top - height * 0.23),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + width * 0.5, top - height * 0.23)
        ..lineTo(left + width * 0.65, top - height * 0.19)
        ..lineTo(left + width * 0.5, top - height * 0.15),
      paint,
    );

    for (var i = 0; i < 3; i++) {
      final x = left + width * (0.25 + i * 0.2);
      canvas.drawLine(
        Offset(x, top + height * 0.4),
        Offset(x, top + height * 0.82),
        paint,
      );
    }
  }

  void _drawTrees(Canvas canvas, Size size, Paint paint) {
    final baseY = size.height * 0.31;
    final xs = [size.width * 0.84, size.width * 0.91];

    for (final x in xs) {
      final tree = Path()
        ..moveTo(x, baseY - 70)
        ..lineTo(x - 24, baseY - 18)
        ..lineTo(x - 9, baseY - 18)
        ..lineTo(x - 29, baseY + 26)
        ..lineTo(x + 29, baseY + 26)
        ..lineTo(x + 9, baseY - 18)
        ..lineTo(x + 24, baseY - 18)
        ..close();
      canvas.drawPath(tree, paint);
    }
  }

  void _drawDots(Canvas canvas, Offset origin, Color color) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.24 : 0.28);
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        canvas.drawCircle(
          origin + Offset(column * 18, row * 18),
          2.2,
          dotPaint,
        );
      }
    }
  }

  void _drawBottomWaves(Canvas canvas, Size size, Color color) {
    final first = Paint()
      ..color = color.withValues(alpha: isDark ? 0.11 : 0.13);
    final second = Paint()
      ..color = color.withValues(alpha: isDark ? 0.08 : 0.1);
    final bottom = size.height;

    final waveA = Path()
      ..moveTo(0, bottom - 62)
      ..cubicTo(
        size.width * 0.22,
        bottom - 86,
        size.width * 0.32,
        bottom - 12,
        size.width * 0.55,
        bottom - 44,
      )
      ..cubicTo(
        size.width * 0.78,
        bottom - 76,
        size.width * 0.86,
        bottom - 46,
        size.width,
        bottom - 82,
      )
      ..lineTo(size.width, bottom)
      ..lineTo(0, bottom)
      ..close();

    final waveB = Path()
      ..moveTo(0, bottom - 34)
      ..cubicTo(
        size.width * 0.18,
        bottom - 54,
        size.width * 0.33,
        bottom + 4,
        size.width * 0.52,
        bottom - 22,
      )
      ..cubicTo(
        size.width * 0.72,
        bottom - 50,
        size.width * 0.88,
        bottom - 28,
        size.width,
        bottom - 54,
      )
      ..lineTo(size.width, bottom)
      ..lineTo(0, bottom)
      ..close();

    canvas.drawPath(waveA, first);
    canvas.drawPath(waveB, second);
  }

  @override
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
