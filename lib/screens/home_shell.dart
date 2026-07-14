import 'package:flutter/material.dart';

import '../models/active_session.dart';
import '../models/attendance_record.dart';
import '../models/course_progress.dart';
import '../models/student.dart';
import '../services/attendance_history_service.dart';
import '../services/course_progress_service.dart';
import '../services/live_session_service.dart';
import '../widgets/bottom_nav.dart';
import 'courses_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'student_dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.student,
    required this.onLogout,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final Student student;
  final VoidCallback onLogout;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _historyService = const AttendanceHistoryService();
  final _courseService = const CourseProgressService();
  final _liveSessionService = LiveSessionService();
  late Future<List<AttendanceRecord>> _historyFuture;
  late Future<List<CourseProgress>> _coursesFuture;
  List<ActiveSession> _activeSessions = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.fetchHistory();
    _coursesFuture = _courseService.fetchCourses();
    _liveSessionService.fetchActiveSessions().then((sessions) {
      if (mounted) setState(() => _activeSessions = sessions);
    });
    _liveSessionService.connect(
      onStarted: (session) {
        if (!mounted) return;
        setState(() {
          _activeSessions = [
            for (final s in _activeSessions)
              if (s.sessionId != session.sessionId) s,
            session,
          ];
        });
      },
      onEnded: (sessionId) {
        if (!mounted) return;
        setState(() {
          _activeSessions = _activeSessions
              .where((s) => s.sessionId != sessionId)
              .toList();
        });
      },
      onEnrollApproved: (session) {
        if (!mounted) return;
        _refreshAttendanceData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${session.courseName} dersine kaydınız onaylandı, yoklamanız işlendi.',
            ),
          ),
        );
      },
      onEnrollRejected: (session) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${session.courseName} dersine katılım isteğiniz hoca tarafından reddedildi.',
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _liveSessionService.dispose();
    super.dispose();
  }

  // Dashboard, Geçmiş ve Derslerim sekmeleri aynı IndexedStack içinde canlı kaldığı
  // için tek bir yoklama verisi kaynağını paylaşırlar — biri QR okuttuktan ya da
  // elle yenileyince hepsi aynı anda güncel veriyi görür, ayrı ayrı bayatlama
  // riski olmaz.
  void _refreshAttendanceData() {
    setState(() {
      _historyFuture = _historyService.fetchHistory();
      _coursesFuture = _courseService.fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentDashboardScreen(
        key: const PageStorageKey('tab-dashboard'),
        student: widget.student,
        historyFuture: _historyFuture,
        onAttendanceUpdated: _refreshAttendanceData,
        activeSessions: _activeSessions,
      ),
      HistoryScreen(
        key: const PageStorageKey('tab-history'),
        historyFuture: _historyFuture,
        onRefresh: _refreshAttendanceData,
      ),
      CoursesScreen(
        key: const PageStorageKey('tab-courses'),
        coursesFuture: _coursesFuture,
        historyFuture: _historyFuture,
        onRefresh: _refreshAttendanceData,
      ),
      ProfileScreen(
        key: const PageStorageKey('tab-profile'),
        student: widget.student,
        onLogout: widget.onLogout,
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}
