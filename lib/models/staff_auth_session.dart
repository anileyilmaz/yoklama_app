import 'staff_user.dart';

class StaffAuthSession {
  const StaffAuthSession({required this.staffUser, required this.token});

  final StaffUser staffUser;
  final String token;
}
