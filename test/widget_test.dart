import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yoklama_app/main.dart';
import 'package:yoklama_app/services/auth_token_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows welcome screen first', (WidgetTester tester) async {
    await tester.pumpWidget(AttendanceApp(tokenStore: _FakeAuthTokenStore()));
    await tester.pumpAndSettle();

    expect(find.text('Yoklama'), findsOneWidget);
    expect(find.text('Başlayalım'), findsOneWidget);
  });
}

class _FakeAuthTokenStore implements AuthTokenStore {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }
}
