import 'auth_session.dart';
import 'staff_auth_session.dart';

/// `UnifiedLoginService.login`'in dönebileceği iki sonuç tipi — hangi domain
/// seçildiğine göre backend'in `kind: "student"|"staff"` alanından türetilir
/// (bkz. lib/services/unified_login_service.dart).
sealed class UnifiedLoginResult {
  const UnifiedLoginResult();
}

class StudentLoginResult extends UnifiedLoginResult {
  const StudentLoginResult(this.session);

  final AuthSession session;
}

class StaffLoginResult extends UnifiedLoginResult {
  const StaffLoginResult(this.session);

  final StaffAuthSession session;
}
