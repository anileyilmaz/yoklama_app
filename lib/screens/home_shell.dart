import 'package:flutter/material.dart';

import '../models/student.dart';
import '../widgets/bottom_nav.dart';
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
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentDashboardScreen(student: widget.student),
      const HistoryScreen(),
      ProfileScreen(
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
