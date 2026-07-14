import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/auth_session.dart';
import 'models/student.dart';
import 'screens/student_info_screen.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/api_config.dart';
import 'services/auth_token_store.dart';
import 'theme/app_theme.dart';

/// Geliştirme sunucusu self-signed sertifika kullanıyor (bkz. ApiConfig.baseUrl).
/// Bu override SADECE ApiConfig'in işaret ettiği host için sertifika hatasını
/// yok sayar — prod'da gerçek bir sertifikaya geçilince bu dosyaya dokunmaya
/// gerek kalmaz, host eşleşmediği sürece devre dışı kalır.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final trustedHost = Uri.parse(ApiConfig.baseUrl).host;
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => host == trustedHost;
  }
}

void main() {
  HttpOverrides.global = _DevHttpOverrides();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatefulWidget {
  const AttendanceApp({
    super.key,
    this.tokenStore = const SecureAuthTokenStore(),
  });

  final AuthTokenStore tokenStore;

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
        tokenStore: widget.tokenStore,
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
    required this.tokenStore,
  });

  final bool darkMode;
  final bool themeLoaded;
  final ValueChanged<bool> onDarkModeChanged;
  final AuthTokenStore tokenStore;

  @override
  State<StudentGate> createState() => _StudentGateState();
}

class _StudentGateState extends State<StudentGate> {
  static const _studentKey = 'student';

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
    final student = Student.fromJson(prefs.getString(_studentKey));
    final token = await widget.tokenStore.readToken();

    if (student == null || token == null || token.isEmpty) {
      await prefs.remove(_studentKey);
      await widget.tokenStore.clearToken();
    }

    setState(() {
      _student = student != null && token != null && token.isNotEmpty
          ? student
          : null;
      _loading = false;
    });
  }

  Future<void> _saveStudent(AuthSession session, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await widget.tokenStore.saveToken(session.token);
    if (rememberMe) {
      await prefs.setString(_studentKey, jsonEncode(session.student.toJson()));
    } else {
      await prefs.remove(_studentKey);
    }
    setState(() => _student = session.student);
  }

  Future<void> _clearStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentKey);
    await widget.tokenStore.clearToken();
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
        key: ValueKey(student.number),
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
