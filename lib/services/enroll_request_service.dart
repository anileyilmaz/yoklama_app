import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/enroll_request.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class EnrollRequestService {
  const EnrollRequestService({
    AuthTokenStore tokenStore = const SecureAuthTokenStore(),
    http.Client? client,
  }) : this._(tokenStore, client);

  const EnrollRequestService._(this._tokenStore, this._client);

  final AuthTokenStore _tokenStore;
  final http.Client? _client;

  Future<List<EnrollRequest>> fetchPending(int sessionId) async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final response = await client
        .get(
          Uri.parse(
            '${ApiConfig.staffBaseUrl}/sessions/$sessionId/enroll-requests',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const EnrollRequestException('Onay bekleyen istekler alınamadı.');
    }
    final decoded = _decode(response.body);
    final list = decoded is List ? decoded : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(EnrollRequest.fromJson)
        .toList();
  }

  Future<void> approve(int sessionId, int requestId) =>
      _decide(sessionId, requestId, 'approve');

  Future<void> reject(int sessionId, int requestId) =>
      _decide(sessionId, requestId, 'reject');

  Future<void> _decide(int sessionId, int requestId, String action) async {
    final token = await _requireToken();
    final client = _client ?? http.Client();
    final response = await client
        .post(
          Uri.parse(
            '${ApiConfig.staffBaseUrl}/sessions/$sessionId/enroll-requests/$requestId/$action',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 12))
        .onError<SocketException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        })
        .onError<TimeoutException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        })
        .onError<http.ClientException>((error, stackTrace) {
          throw const EnrollRequestException('Sunucuya ulaşılamıyor');
        });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const EnrollRequestException('İstek işlenemedi.');
    }
  }

  Future<String> _requireToken() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      throw const EnrollRequestException(
        'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }
    return token;
  }

  Object? _decode(String source) {
    if (source.trim().isEmpty) return const {};
    try {
      return jsonDecode(source);
    } on FormatException {
      return const {};
    }
  }
}

class EnrollRequestException implements Exception {
  const EnrollRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
