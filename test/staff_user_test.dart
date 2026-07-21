import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:yoklama_app/models/staff_user.dart';

void main() {
  test('toJson/fromJson round-trip preserves all fields', () {
    const user = StaffUser(
      username: 'hoca1',
      name: 'Ayşe Hoca',
      role: 'teacher',
      facultyId: 3,
      facultyName: 'Mühendislik Fakültesi',
    );

    final restored = StaffUser.fromJson(jsonEncode(user.toJson()));

    expect(restored, isNotNull);
    expect(restored!.username, 'hoca1');
    expect(restored.name, 'Ayşe Hoca');
    expect(restored.role, 'teacher');
    expect(restored.facultyId, 3);
    expect(restored.facultyName, 'Mühendislik Fakültesi');
  });

  test('fromJson returns null for empty or null source', () {
    expect(StaffUser.fromJson(null), isNull);
    expect(StaffUser.fromJson(''), isNull);
  });
}
