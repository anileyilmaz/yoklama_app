import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/enroll_request.dart';
import '../models/live_attendance_entry.dart';
import '../services/enroll_request_service.dart';
import '../services/teacher_live_session_socket.dart';
import '../services/teacher_session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({
    super.key,
    required this.sessionId,
    required this.courseName,
  });

  final int sessionId;
  final String courseName;

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  final _sessionService = const TeacherSessionService();
  final _enrollRequestService = const EnrollRequestService();
  final _socket = TeacherLiveSessionSocket();

  String? _qrPayload;
  final List<LiveAttendanceEntry> _attendees = [];
  final List<EnrollRequest> _pendingRequests = [];
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _sessionService.fetchDetail(widget.sessionId).then((detail) {
      if (mounted && detail.qr != null) setState(() => _qrPayload = detail.qr);
    });
    _enrollRequestService.fetchPending(widget.sessionId).then((requests) {
      if (mounted) setState(() => _pendingRequests.addAll(requests));
    });
    _socket.watch(
      sessionId: widget.sessionId,
      onQr: (payload, windowMs) {
        if (mounted) setState(() => _qrPayload = payload);
      },
      onAttendance: (entry) {
        if (mounted) setState(() => _attendees.insert(0, entry));
      },
      onEnrollRequest: (request) {
        if (mounted) setState(() => _pendingRequests.add(request));
      },
      onSessionEnded: () {
        if (mounted) setState(() => _ended = true);
      },
    );
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  Future<void> _approve(EnrollRequest request) async {
    setState(() => _pendingRequests.removeWhere((r) => r.id == request.id));
    try {
      await _enrollRequestService.approve(widget.sessionId, request.id);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _pendingRequests.add(request));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _reject(EnrollRequest request) async {
    setState(() => _pendingRequests.removeWhere((r) => r.id == request.id));
    try {
      await _enrollRequestService.reject(widget.sessionId, request.id);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _pendingRequests.add(request));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _end() async {
    try {
      await _sessionService.endSession(widget.sessionId);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  // Yeni öğrenciyi burada listeye eklemiyoruz — backend başarılı elle ekleme
  // sonrası aynı "attendance" socket event'ini yayınlıyor (bkz.
  // TeacherLiveSessionSocket.onAttendance), o event zaten mevcut canlı listeye
  // ekliyor. Dialog, hata durumunda bu Future'ın attığı exception'ı yakalayıp
  // kendi içinde gösteriyor (bkz. LiveSessionBody'deki _AddManualDialog).
  Future<void> _addManual(String studentNumber) async {
    await _sessionService.addManualAttendance(widget.sessionId, studentNumber);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Öğrenci eklendi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
    return LiveSessionBody(
      courseName: widget.courseName,
      qrPayload: _qrPayload,
      attendees: _attendees,
      pendingRequests: _pendingRequests,
      onApprove: _approve,
      onReject: _reject,
      onEnd: _end,
      onAddManual: _addManual,
    );
  }
}

/// Saf sunum widget'ı — canlı veri `LiveSessionScreen`'in socket/servis
/// bağlantısından beslenir, ama bu widget'ın kendisi test edilebilmesi için o
/// bağlantılara hiç dokunmaz (bkz. dashboard_live_session_test.dart'taki aynı
/// desen: gerçek socket yerine veriyi doğrudan constructor'dan alır).
class LiveSessionBody extends StatelessWidget {
  const LiveSessionBody({
    super.key,
    required this.courseName,
    required this.qrPayload,
    required this.attendees,
    required this.pendingRequests,
    required this.onApprove,
    required this.onReject,
    required this.onEnd,
    required this.onAddManual,
  });

  final String courseName;
  final String? qrPayload;
  final List<LiveAttendanceEntry> attendees;
  final List<EnrollRequest> pendingRequests;
  final ValueChanged<EnrollRequest> onApprove;
  final ValueChanged<EnrollRequest> onReject;
  final VoidCallback onEnd;
  final Future<void> Function(String studentNumber) onAddManual;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
        actions: [
          IconButton(
            tooltip: 'Öğrenci ekle',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _AddManualDialog(onAddManual: onAddManual),
            ),
          ),
          TextButton(
            onPressed: onEnd,
            child: const Text('Oturumu bitir'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: SoftCard(
                child: qrPayload == null
                    ? const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : QrImageView(data: qrPayload!, size: 220),
              ),
            ),
            const SizedBox(height: 20),
            if (pendingRequests.isNotEmpty) ...[
              Text(
                'Onay bekleyen istekler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final request in pendingRequests) ...[
                SoftCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request.name),
                            Text(
                              request.studentNumber,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.mutedOf(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () => onApprove(request),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: AppColors.danger,
                        ),
                        onPressed: () => onReject(request),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
            ],
            Text(
              'Katılımlar (${attendees.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final entry in attendees) ...[
              SoftCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name),
                          Text(
                            entry.studentNumber,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      entry.createdAt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddManualDialog extends StatefulWidget {
  const _AddManualDialog({required this.onAddManual});

  final Future<void> Function(String studentNumber) onAddManual;

  @override
  State<_AddManualDialog> createState() => _AddManualDialogState();
}

class _AddManualDialogState extends State<_AddManualDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final studentNumber = _controller.text.trim();
    if (studentNumber.isEmpty) {
      setState(() => _error = 'Öğrenci numarası zorunlu');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onAddManual(studentNumber);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Öğrenci ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            enabled: !_submitting,
            decoration: const InputDecoration(labelText: 'Öğrenci Numarası'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ekle'),
        ),
      ],
    );
  }
}
