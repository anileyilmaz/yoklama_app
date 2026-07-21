import 'package:flutter/material.dart';

import '../models/live_attendance_entry.dart';
import '../models/teaching_session_summary.dart';
import '../services/teacher_session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';

class TeacherSessionHistoryScreen extends StatelessWidget {
  const TeacherSessionHistoryScreen({super.key, required this.historyFuture});

  final Future<List<TeachingSessionSummary>> historyFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Oturumlar')),
      body: SafeArea(
        child: FutureBuilder<List<TeachingSessionSummary>>(
          future: historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SoftCard(
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final sessions = snapshot.data ?? const <TeachingSessionSummary>[];
            if (sessions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SoftCard(
                    child: Text(
                      'Henüz bir yoklama oturumu başlatmadınız.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    for (final session in sessions) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _SessionAttendanceScreen(
                              sessionId: session.id,
                              courseName: session.courseName,
                            ),
                          ),
                        ),
                        child: SoftCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.courseName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      session.createdAt,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.mutedOf(context),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text('${session.count} katılım'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
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

class _SessionAttendanceScreen extends StatefulWidget {
  const _SessionAttendanceScreen({
    required this.sessionId,
    required this.courseName,
  });

  final int sessionId;
  final String courseName;

  @override
  State<_SessionAttendanceScreen> createState() =>
      _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<_SessionAttendanceScreen> {
  final _sessionService = const TeacherSessionService();
  late Future<List<LiveAttendanceEntry>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _sessionService.fetchAttendance(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName)),
      body: SafeArea(
        child: FutureBuilder<List<LiveAttendanceEntry>>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data ?? const <LiveAttendanceEntry>[];
            if (entries.isEmpty) {
              return const Center(child: Text('Bu oturumda katılım yok.'));
            }
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                for (final entry in entries) ...[
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
                                    ?.copyWith(
                                      color: AppColors.mutedOf(context),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(entry.createdAt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
