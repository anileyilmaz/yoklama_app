import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/student.dart';
import 'screens/student_info_screen.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key});

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  bool _darkMode = false;
  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _themeLoaded = true;
    });
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoklama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StudentGate(
        darkMode: _darkMode,
        themeLoaded: _themeLoaded,
        onDarkModeChanged: _setDarkMode,
      ),
    );
  }
}

class StudentGate extends StatefulWidget {
  const StudentGate({
    super.key,
    required this.darkMode,
    required this.themeLoaded,
    required this.onDarkModeChanged,
  });

  final bool darkMode;
  final bool themeLoaded;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<StudentGate> createState() => _StudentGateState();
}

class _StudentGateState extends State<StudentGate> {
  Student? _student;
  bool _loading = true;
  bool _showInfoForm = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _student = Student.fromJson(prefs.getString('student'));
      _loading = false;
    });
  }

  Future<void> _saveStudent(Student student, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('student', jsonEncode(student.toJson()));
    } else {
      await prefs.remove('student');
    }
    setState(() => _student = student);
  }

  Future<void> _clearStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student');
    setState(() {
      _student = null;
      _showInfoForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !widget.themeLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final student = _student;
    if (student != null) {
      return HomeShell(
        student: student,
        onLogout: _clearStudent,
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      );
    }

    if (_showInfoForm) {
      return StudentInfoScreen(onSaved: _saveStudent);
    }

    return WelcomeScreen(onStart: () => setState(() => _showInfoForm = true));
  }
}
