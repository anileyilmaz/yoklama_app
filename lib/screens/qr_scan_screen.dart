import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/attendance_session.dart';
import '../models/student.dart';
import '../services/attendance_api.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
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
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
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
            Container(color: AppColors.dark.withValues(alpha: 0.68)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        tooltip: 'Geri',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'QR Kod Oku',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 58),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lutfen tahtadaki QR kodu cerceve icine alin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 310),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 170,
                                  color: Colors.white,
                                ),
                              ),
                              if (_submitting)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundAction(
                        icon: Icons.photo_library_outlined,
                        label: 'Galeriden Sec',
                        onTap: _manualEntry,
                      ),
                      _RoundAction(
                        icon: Icons.flash_on_rounded,
                        label: 'Fener',
                        onTap: _controller.toggleTorch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualEntry() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => const _ManualCodeDialog(),
    );
    if (!mounted || value == null || value.isEmpty) return;
    await _submitQr(value);
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
      ).showSnackBar(SnackBar(content: Text('Yoklama gonderilemedi: $error')));
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

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onTap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            foregroundColor: Colors.white,
            fixedSize: const Size(56, 56),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _controller = TextEditingController(
    text: '{"sessionCode":"VP-101","lesson":"Veri Yapilari"}',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('QR kodu'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Oturum kodu veya QR icerigi',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgec'),
        ),
        SizedBox(
          width: 120,
          child: GradientButton(
            label: 'Gonder',
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ),
      ],
    );
  }
}
