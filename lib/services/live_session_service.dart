import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../models/active_session.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

/// Öğrencinin kayıtlı olduğu bir derste yoklama açıldığında/kapandığında uygulama
/// açıkken anlık bildirim almasını sağlar. `fetchActiveSessions` uygulama ilk
/// açıldığındaki (henüz bir socket event'i gelmemiş) durumu, `connect` ise
/// sonrasındaki değişiklikleri anlık verir.
class LiveSessionService {
  LiveSessionService({this._tokenStore = const SecureAuthTokenStore()});

  final AuthTokenStore _tokenStore;
  socket_io.Socket? _socket;

  Future<List<ActiveSession>> fetchActiveSessions() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) return const [];

    final base = Uri.parse(ApiConfig.baseUrl.trim());
    final endpoint = base.replace(path: _joinPath(base.path, '/active-sessions'));

    try {
      final response = await http
          .get(endpoint, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return const [];
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ActiveSession.fromJson)
          .toList();
    } on SocketException {
      return const [];
    } on TimeoutException {
      return const [];
    } on http.ClientException {
      return const [];
    }
  }

  Future<void> connect({
    required void Function(ActiveSession session) onStarted,
    required void Function(int sessionId) onEnded,
    void Function(ActiveSession session)? onEnrollApproved,
    void Function(ActiveSession session)? onEnrollRejected,
  }) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) return;

    _socket?.dispose();
    final socket = socket_io.io(
      ApiConfig.socketOrigin,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    socket.on('course:sessionStarted', (data) {
      if (data is Map) {
        onStarted(ActiveSession.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.on('course:sessionEnded', (data) {
      if (data is Map) {
        final sessionId = (data['sessionId'] as num?)?.toInt();
        if (sessionId != null) onEnded(sessionId);
      }
    });
    // Derse kayıtlı olmadan QR okutup hocaya onay isteği gönderdiğinde (bkz.
    // AttendanceException.pending) sonucu anlık bildirir — öğrenci kayıtlı
    // olmadığı derslerin odalarına giremediği için sunucu bunu kişisel
    // "student-<id>" odası üzerinden gönderir (bkz. server.js socket.io bölümü).
    socket.on('enrollRequest:approved', (data) {
      if (data is Map && onEnrollApproved != null) {
        onEnrollApproved(ActiveSession.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.on('enrollRequest:rejected', (data) {
      if (data is Map && onEnrollRejected != null) {
        onEnrollRejected(ActiveSession.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.connect();
    _socket = socket;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }

  String _joinPath(String basePath, String path) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
