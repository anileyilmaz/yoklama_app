import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../models/enroll_request.dart';
import '../models/live_attendance_entry.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

/// Hocanın canlı oturum ekranı için socket.io bağlantısı — öğrenci tarafındaki
/// `LiveSessionService`'ten ayrı bir sınıf: farklı oda (`session-<id>`, bağlanınca
/// `watch(sessionId)` emit edilerek katılınır) ve farklı event sözleşmesi
/// (qr/attendance/enrollRequest/sessionEnded) kullanır.
class TeacherLiveSessionSocket {
  TeacherLiveSessionSocket({this._tokenStore = const SecureAuthTokenStore()});

  final AuthTokenStore _tokenStore;
  socket_io.Socket? _socket;

  Future<void> watch({
    required int sessionId,
    required void Function(String payload, int windowMs) onQr,
    required void Function(LiveAttendanceEntry entry) onAttendance,
    required void Function(EnrollRequest request) onEnrollRequest,
    required void Function() onSessionEnded,
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
    socket.on('qr', (data) {
      if (data is Map) {
        final payload = data['payload'] as String?;
        final windowMs = (data['windowMs'] as num?)?.toInt();
        if (payload != null && windowMs != null) onQr(payload, windowMs);
      }
    });
    socket.on('attendance', (data) {
      if (data is Map) {
        onAttendance(
          LiveAttendanceEntry.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    });
    socket.on('enrollRequest', (data) {
      if (data is Map) {
        onEnrollRequest(EnrollRequest.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.on('sessionEnded', (_) => onSessionEnded());
    socket.onConnect((_) => socket.emit('watch', sessionId));
    socket.connect();
    _socket = socket;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
