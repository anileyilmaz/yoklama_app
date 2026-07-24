import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/auth_session.dart';
import 'models/staff_auth_session.dart';
import 'models/staff_user.dart';
import 'models/student.dart';
import 'models/unified_login_result.dart';
import 'screens/login_screen.dart';
import 'screens/teacher_home_shell.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/api_config.dart';
import 'services/auth_token_store.dart';
import 'theme/app_theme.dart';

/// Geliştirme sunucusu self-signed sertifika kullanıyor (bkz. ApiConfig.baseUrl).
/// Bu override SADECE ApiConfig'in işaret ettiği host için sertifika hatasını
/// yok sayar — prod'da gerçek bir sertifikaya geçilince bu dosyaya dokunmaya
/// gerek kalmaz, host eşleşmediği sürece devre dışı kalır.
///
/// GÜVENLİK: `main()` bunu yalnızca `kDebugMode`da etkinleştirir — release build'de
/// hiçbir sertifika bypass'ı olmaz. Bu satır olmadan kDebugMode kontrolsüz her build'e
/// (release dahil) sızar ve o host için MITM'e karşı korumasız kalır.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final trustedHost = Uri.parse(ApiConfig.baseUrl).host;
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => host == trustedHost;
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }
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
      home: AppGate(
        darkMode: _darkMode,
        themeLoaded: _themeLoaded,
        onDarkModeChanged: _setDarkMode,
        tokenStore: widget.tokenStore,
      ),
    );
  }
}

enum _EntryScreen { welcome, login }

class AppGate extends StatefulWidget {
  const AppGate({
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
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  static const _studentKey = 'student';
  static const _roleKey = 'role';
  static const _staffUserKey = 'staffUser';

  Student? _student;
  StaffUser? _staffUser;
  bool _loading = true;
  _EntryScreen _entryScreen = _EntryScreen.welcome;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await widget.tokenStore.readToken();
    final role = prefs.getString(_roleKey);

    if (token == null || token.isEmpty) {
      await _clearAll(prefs);
      setState(() => _loading = false);
      return;
    }

    if (role == 'teacher') {
      final staffUser = StaffUser.fromJson(prefs.getString(_staffUserKey));
      if (staffUser == null) {
        await _clearAll(prefs);
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _staffUser = staffUser;
        _loading = false;
      });
      return;
    }

    // role == 'student' veya eski kurulumlarda role hiç yazılmamış (geriye
    // dönük uyumluluk) — ikisinde de öğrenci verisi kontrol edilir.
    final student = Student.fromJson(prefs.getString(_studentKey));
    if (student == null) {
      await _clearAll(prefs);
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _student = student;
      _loading = false;
    });
  }

  Future<void> _clearAll(SharedPreferences prefs) async {
    await prefs.remove(_studentKey);
    await prefs.remove(_staffUserKey);
    await prefs.remove(_roleKey);
    await widget.tokenStore.clearToken();
  }

  Future<void> _saveStudent(AuthSession session, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await widget.tokenStore.saveToken(session.token);
    await prefs.setString(_roleKey, 'student');
    await prefs.remove(_staffUserKey);
    if (rememberMe) {
      await prefs.setString(_studentKey, jsonEncode(session.student.toJson()));
    } else {
      await prefs.remove(_studentKey);
    }
    setState(() => _student = session.student);
  }

  Future<void> _saveStaff(StaffAuthSession session, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await widget.tokenStore.saveToken(session.token);
    await prefs.setString(_roleKey, 'teacher');
    if (rememberMe) {
      await prefs.setString(
        _staffUserKey,
        jsonEncode(session.staffUser.toJson()),
      );
    } else {
      await prefs.remove(_staffUserKey);
    }
    await prefs.remove(_studentKey);
    setState(() => _staffUser = session.staffUser);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearAll(prefs);
    setState(() {
      _student = null;
      _staffUser = null;
      _entryScreen = _EntryScreen.login;
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
        key: ValueKey('student-${student.number}'),
        student: student,
        onLogout: _logout,
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      );
    }

    final staffUser = _staffUser;
    if (staffUser != null) {
      return TeacherHomeShell(
        key: ValueKey('teacher-${staffUser.username}'),
        staffUser: staffUser,
        onLogout: _logout,
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      );
    }

    switch (_entryScreen) {
      case _EntryScreen.welcome:
        return WelcomeScreen(
          onStart: () => setState(() => _entryScreen = _EntryScreen.login),
        );
      case _EntryScreen.login:
        return LoginScreen(
          onSaved: (result, rememberMe) => switch (result) {
            StudentLoginResult(:final session) =>
              _saveStudent(session, rememberMe),
            StaffLoginResult(:final session) => _saveStaff(session, rememberMe),
          },
        );
    }
  }
}
