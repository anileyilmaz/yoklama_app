import 'package:flutter/material.dart';

import '../models/staff_user.dart';
import '../models/teacher_course.dart';
import '../models/teaching_session_summary.dart';
import '../services/teacher_courses_service.dart';
import '../services/teacher_session_service.dart';
import '../widgets/bottom_nav.dart';
import 'live_session_screen.dart';
import 'teacher_courses_screen.dart';
import 'teacher_profile_screen.dart';
import 'teacher_report_screen.dart';
import 'teacher_session_history_screen.dart';

class TeacherHomeShell extends StatefulWidget {
  const TeacherHomeShell({
    super.key,
    required this.staffUser,
    required this.onLogout,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final StaffUser staffUser;
  final VoidCallback onLogout;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<TeacherHomeShell> createState() => _TeacherHomeShellState();
}

class _TeacherHomeShellState extends State<TeacherHomeShell> {
  final _coursesService = const TeacherCoursesService();
  final _sessionService = const TeacherSessionService();
  late Future<List<TeacherCourse>> _coursesFuture;
  late Future<List<TeachingSessionSummary>> _historyFuture;
  int _index = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Derslerim',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_rounded),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'Geçmiş',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_rounded),
      selectedIcon: Icon(Icons.bar_chart_rounded),
      label: 'Rapor',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _coursesFuture = _coursesService.fetchCourses();
    _historyFuture = _sessionService.fetchHistory();
  }

  void _refresh() {
    setState(() {
      _coursesFuture = _coursesService.fetchCourses();
      _historyFuture = _sessionService.fetchHistory();
    });
  }

  Future<void> _openLiveSession(int sessionId, String courseName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LiveSessionScreen(sessionId: sessionId, courseName: courseName),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TeacherCoursesScreen(
        key: const PageStorageKey('teacher-tab-courses'),
        coursesFuture: _coursesFuture,
        onSessionStarted: _openLiveSession,
      ),
      TeacherSessionHistoryScreen(
        key: const PageStorageKey('teacher-tab-history'),
        historyFuture: _historyFuture,
      ),
      TeacherReportScreen(
        key: const PageStorageKey('teacher-tab-report'),
        coursesFuture: _coursesFuture,
      ),
      TeacherProfileScreen(
        key: const PageStorageKey('teacher-tab-profile'),
        staffUser: widget.staffUser,
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
        destinations: _destinations,
      ),
    );
  }
}
