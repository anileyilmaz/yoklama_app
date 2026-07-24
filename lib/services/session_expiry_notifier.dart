import 'dart:async';

/// Kimlik doğrulamalı bir API çağrısı 401 aldığında yayın yapar; `AppGate`
/// bunu dinleyip yerel oturumu temizleyip kullanıcıyı giriş ekranına
/// düşürür — web panellerindeki `api()` helper'ının (`if (res.status ===
/// 401) return logout();`, bkz. admin.html/hoca.html) mobil karşılığı.
class SessionExpiryNotifier {
  SessionExpiryNotifier._();

  static final SessionExpiryNotifier instance = SessionExpiryNotifier._();

  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notify() => _controller.add(null);
}
