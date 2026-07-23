import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:yoklama_app/screens/register_screen.dart';
import 'package:yoklama_app/services/register_service.dart';

void main() {
  testWidgets(
    'shows the student number field with a locked ogrenci.ege.edu.tr domain badge',
    (tester) async {
      // Gerçek RegisterService yerine anında boş liste dönen bir MockClient
      // enjekte edilir — aksi halde gerçek bir ağ isteği initState'te atılır ve
      // fakülte listesi yüklenene kadar gösterilen sonsuz CircularProgressIndicator
      // pumpAndSettle'ın hiç durulmamasına yol açar (bkz. bu dosyadaki Step 1'in
      // üstündeki not, aynı tuzağın _AddManualDialog testindeki karşılığı).
      final registerService = RegisterService(
        client: MockClient((request) async {
          return http.Response(jsonEncode([]), 200);
        }),
      );

      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(registerService: registerService)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Öğrenci Numarası'), findsOneWidget);
      expect(find.text('ogrenci.ege.edu.tr'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsNothing);
    },
  );
}
