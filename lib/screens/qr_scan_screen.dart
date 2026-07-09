import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/attendance_session.dart';
import '../models/student.dart';
import '../services/attendance_api.dart';
import '../theme/app_theme.dart';
import 'success_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, required this.student});

  final Student student;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _controller = MobileScannerController();
  final _api = const AttendanceApi();
  bool _handled = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071116),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => const _CameraPlaceholder(),
              errorBuilder: (context, error) =>
                  _CameraPermissionView(message: _cameraErrorMessage(error)),
              onDetect: (capture) {
                if (_handled) return;
                final value = capture.barcodes.isEmpty
                    ? null
                    : capture.barcodes.first.rawValue;
                if (value == null || value.isEmpty) return;
                _handled = true;
                _submitQr(value);
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xff061015).withValues(alpha: 0.92),
                    const Color(0xff061015).withValues(alpha: 0.54),
                    const Color(0xff061015).withValues(alpha: 0.86),
                  ],
                  stops: const [0, 0.46, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 380
                    ? 20.0
                    : 26.0;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    22,
                  ),
                  child: Column(
                    children: [
                      const _ScannerHeader(),
                      const SizedBox(height: 38),
                      Text(
                        'QR kodu çerçevenin içine hizalayın',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 34),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                children: [
                                  const Positioned.fill(child: _ScannerFrame()),
                                  if (_submitting)
                                    const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _SecurityInfoCard(),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _TorchButton(controller: _controller),
                      ),
                      const SizedBox(height: 18),
                      _CancelButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _cameraErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Kamera izni gerekebilir';
      default:
        return 'Kamera başlatılamadı';
    }
  }

  Future<void> _submitQr(String value) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final session = AttendanceSession.fromQr(value);
      final result = await _api.submit(
        student: widget.student,
        session: session,
      );
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SuccessScreen(result: result)));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yoklama gönderilemedi: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _handled = false;
        });
      }
    }
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
              iconSize: 34,
            ),
          ),
          Text(
            'QR Kod Okut',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerFramePainter(),
      child: Center(
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.qr_code_2_rounded,
            color: Colors.white.withValues(alpha: 0.14),
            size: 72,
          ),
        ),
      ),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  const _SecurityInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xff0b2224).withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.accent,
            size: 42,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'QR kodlar güvenlik için kısa süreli geçerlidir.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        final isOn = state.torchState == TorchState.on;
        final isAvailable = state.torchState != TorchState.unavailable;

        return Tooltip(
          message: isOn ? 'Feneri kapat' : 'Feneri aç',
          child: IconButton.filled(
            onPressed: isAvailable ? controller.toggleTorch : null,
            icon: Icon(isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            style: IconButton.styleFrom(
              backgroundColor: isOn
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.13),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.07),
              foregroundColor: isOn ? const Color(0xff05211d) : Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
              fixedSize: const Size(58, 58),
            ),
          ),
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.82)),
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        child: const Text('İptal'),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff071116),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class _CameraPermissionView extends StatelessWidget {
  const _CameraPermissionView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff071116),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xff171b16).withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.42),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.amber,
              size: 34,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xffffd27a),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = const Color(0xff7cffd7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xff2eeaa1).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final scanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x002eea9f),
          Color(0xff2eea9f),
          Color(0xffffffff),
          Color(0xff2eea9f),
          Color(0x002eea9f),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 4))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.09;
    final corner = size.width * 0.16;
    final radius = Radius.circular(size.width * 0.08);
    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    void drawCorners(Paint paint) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(left + corner, top + corner),
          radius: corner,
        ),
        3.14,
        1.57,
        false,
        paint,
      );
      canvas.drawLine(
        Offset(left + corner, top),
        Offset(left + corner * 1.65, top),
        paint,
      );
      canvas.drawLine(
        Offset(left, top + corner),
        Offset(left, top + corner * 1.65),
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(right - corner, top + corner),
          radius: corner,
        ),
        4.71,
        1.57,
        false,
        paint,
      );
      canvas.drawLine(
        Offset(right - corner, top),
        Offset(right - corner * 1.65, top),
        paint,
      );
      canvas.drawLine(
        Offset(right, top + corner),
        Offset(right, top + corner * 1.65),
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(left + corner, bottom - corner),
          radius: corner,
        ),
        1.57,
        1.57,
        false,
        paint,
      );
      canvas.drawLine(
        Offset(left + corner, bottom),
        Offset(left + corner * 1.65, bottom),
        paint,
      );
      canvas.drawLine(
        Offset(left, bottom - corner),
        Offset(left, bottom - corner * 1.65),
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(right - corner, bottom - corner),
          radius: corner,
        ),
        0,
        1.57,
        false,
        paint,
      );
      canvas.drawLine(
        Offset(right - corner, bottom),
        Offset(right - corner * 1.65, bottom),
        paint,
      );
      canvas.drawLine(
        Offset(right, bottom - corner),
        Offset(right, bottom - corner * 1.65),
        paint,
      );
    }

    final shadePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, bottom), radius),
      shadePaint,
    );

    drawCorners(glowPaint);
    drawCorners(framePaint);
    canvas.drawLine(
      Offset(left, size.height * 0.52),
      Offset(right, size.height * 0.52),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
