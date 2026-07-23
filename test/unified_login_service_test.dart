import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:yoklama_app/models/unified_login_result.dart';
import 'package:yoklama_app/services/device_id_store.dart';
import 'package:yoklama_app/services/unified_login_service.dart';

class _FakeDeviceIdStore implements DeviceIdStore {
  @override
  Future<String> getOrCreateDeviceId() async => 'fake-device-id';
}

void main() {
  test('ogrenci.ege.edu.tr domain: composes identifier and returns StudentLoginResult', () async {
    Map<String, dynamic>? sentBody;
    final service = UnifiedLoginService(
      client: MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'kind': 'student',
            'token': 'tok',
            'student': {
              'id': 1,
              'name': 'Ali Veli',
              'studentNumber': '210101234',
              'department': 'X',
            },
          }),
          200,
        );
      }),
      deviceIdStore: _FakeDeviceIdStore(),
    );

    final result = await service.login(
      value: '210101234',
      domain: kStudentLoginDomain,
      password: 'sifre123',
    );

    expect(sentBody!['identifier'], '210101234@ogrenci.ege.edu.tr');
    expect(sentBody!['deviceId'], 'fake-device-id');
    expect(result, isA<StudentLoginResult>());
    expect((result as StudentLoginResult).session.student.number, '210101234');
  });

  test('ege.edu.tr domain: composes identifier without deviceId and returns StaffLoginResult', () async {
    Map<String, dynamic>? sentBody;
    final service = UnifiedLoginService(
      client: MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'kind': 'staff', 'token': 'tok2', 'role': 'teacher', 'name': 'Ayşe Hoca'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await service.login(
      value: 'hoca1',
      domain: kStaffLoginDomain,
      password: 'sifre123',
    );

    expect(sentBody!['identifier'], 'hoca1@ege.edu.tr');
    expect(sentBody!.containsKey('deviceId'), isFalse);
    expect(result, isA<StaffLoginResult>());
    expect((result as StaffLoginResult).session.staffUser.role, 'teacher');
  });

  test('non-2xx response throws UnifiedLoginException with backend message', () async {
    final service = UnifiedLoginService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Kullanıcı adı veya şifre hatalı.'}),
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await expectLater(
      () => service.login(value: 'hoca1', domain: kStaffLoginDomain, password: 'yanlis'),
      throwsA(
        isA<UnifiedLoginException>().having(
          (e) => e.message,
          'message',
          'Kullanıcı adı veya şifre hatalı.',
        ),
      ),
    );
  });
}
