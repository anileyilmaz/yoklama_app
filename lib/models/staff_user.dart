import 'dart:convert';

class StaffUser {
  const StaffUser({
    required this.username,
    required this.name,
    required this.role,
    this.facultyId,
    this.facultyName,
  });

  final String username;
  final String name;
  final String role;
  final int? facultyId;
  final String? facultyName;

  Map<String, dynamic> toJson() => {
    'username': username,
    'name': name,
    'role': role,
    'facultyId': facultyId,
    'facultyName': facultyName,
  };

  static StaffUser? fromJson(String? source) {
    if (source == null || source.isEmpty) return null;
    final data = jsonDecode(source) as Map<String, dynamic>;
    final username = data['username'] as String?;
    final name = data['name'] as String?;
    final role = data['role'] as String?;
    if (username == null || name == null || role == null) return null;
    return StaffUser(
      username: username,
      name: name,
      role: role,
      facultyId: data['facultyId'] as int?,
      facultyName: data['facultyName'] as String?,
    );
  }
}
