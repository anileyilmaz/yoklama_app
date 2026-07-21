abstract class PasswordChanger {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
