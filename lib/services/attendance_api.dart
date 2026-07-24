import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_result.dart';
import 'api_config.dart';
import 'auth_token_store.dart';
import 'device_id_store.dart';
import 'session_expiry_notifier.dart';

typedef _LocationSnapshot = ({double lat, double lng, bool isMocked});

class AttendanceApi {
  const AttendanceApi({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    DeviceIdStore deviceIdStore = const SecureDeviceIdStore(),
  }) : this._(tokenStore, deviceIdStore);

  const AttendanceApi._(this._tokenStore, this._deviceIdStore);

  final AuthTokenStore _tokenStore;
  final DeviceIdStore _deviceIdStore;

  Future<AttendanceResult> submit({required String qr}) async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const AttendanceException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }

    final deviceId = await _deviceIdStore.getOrCreateDeviceId();
    final location = await _readLocation();

    final base = Uri.parse(ApiConfig.baseUrl.trim());
    final endpoint = base.replace(
      path: _joinPath(base.path, '/attendance/scan'),
    );

    final response = await http
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'qr': qr,
            'lat': location?.lat,
            'lng': location?.lng,
            'mockLocation': location?.isMocked,
            'deviceId': deviceId,
          }),
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const AttendanceException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode == 401) {
      SessionExpiryNotifier.instance.notify();
    }

    final body = _decodeBody(response.body);

    // Öğrenci derse kayıtlı değilse sunucu isteği reddetmez, hocaya onay isteği
    // gönderir ve 202 + pending:true döner (bkz. server.js MOBILE_ENDPOINTS.ATTEND) —
    // ne başarı (henüz yoklama işlenmedi) ne hata (istek kabul edildi), ayrı ele alınır.
    if (response.statusCode == 202 && body['pending'] == true) {
      throw AttendanceException(
        _stringValue(body['message']) ?? 'İsteğiniz öğretim üyenize iletildi.',
        pending: true,
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] != false) {
      return AttendanceResult.success(
        lesson: _lessonFromResponse(body),
        message: _stringValue(body['message']),
      );
    }

    throw AttendanceException(
      _stringValue(body['message']) ??
          _stringValue(body['error']) ??
          'Yoklama gönderilemedi. Lütfen tekrar deneyin.',
    );
  }

  // Konum doğrulaması olmayan oturumlar için bu her zaman denenip başarısızsa
  // sessizce null'a düşer (sunucu zaten session.lat==null'da lat/lng'i görmezden
  // gelir) — sadece konum doğrulamalı bir oturuma katılmaya çalışırken izin
  // reddi/servis kapalı gibi durumlarda sunucudan gelen "konum izni verin" (400)
  // mesajı kullanıcıya net bir yönlendirme olarak zaten görünür.
  //
  // timeLimit KISA tutulur (5 sn): bu istek HTTP çağrısından önce, senkron olarak
  // bekleniyor ve backend'deki QR penceresi artık sadece ~20 sn (bkz. server.js
  // QR_WINDOW_MS) — sınıf içinde zayıf GPS sinyaliyle uzun bir konum beklemesi,
  // isteğin gönderilmesini geciktirip QR'ı süresi dolmadan sunucuya ulaştıramayabilir.
  // Konum alınamazsa zaten null'a düşüp GPS'siz devam ediyoruz, bu yüzden kısa tutmak
  // (sadece hızlı bir fix varsa kullanmak) uzun beklemekten daha iyi bir tercih.
  Future<_LocationSnapshot?> _readLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return (
        lat: position.latitude,
        lng: position.longitude,
        isMocked: position.isMocked,
      );
    } catch (_) {
      return null;
    }
  }

  String _joinPath(String basePath, String apiPath) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase$apiPath';
  }

  Map<String, dynamic> _decodeBody(String source) {
    if (source.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  String? _lessonFromResponse(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final direct =
          _stringValue(data['lesson']) ??
          _stringValue(data['courseName']) ??
          _stringValue(data['course']);
      if (direct != null) return direct;
    }
    // Sunucu şu an ders adını ayrı bir alanda değil, "Yoklamaya katıldınız: <ders>"
    // formatındaki mesaj metninin içinde döner (bkz. server.js MOBILE_ENDPOINTS.ATTEND).
    final message = _stringValue(body['message']);
    if (message != null && message.contains(':')) {
      return message.substring(message.indexOf(':') + 1).trim();
    }
    return null;
  }

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }
}

class AttendanceException implements Exception {
  const AttendanceException(this.message, {this.pending = false});

  final String message;

  /// true ise istek başarısız olmadı — öğrenci derse kayıtlı olmadığı için
  /// hocaya onay isteği gönderildi, sonucu socket.io üzerinden anlık gelecek
  /// (bkz. LiveSessionService.onEnrollApproved/onEnrollRejected).
  final bool pending;

  @override
  String toString() => message;
}
