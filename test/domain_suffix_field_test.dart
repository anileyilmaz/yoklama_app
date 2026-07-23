import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yoklama_app/widgets/domain_suffix_field.dart';

void main() {
  testWidgets('interactive mode shows a dropdown and reports the selected domain', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DomainSuffixField(
            value: 'ege.edu.tr',
            options: const ['ege.edu.tr', 'ogrenci.ege.edu.tr'],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButton<String>), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ogrenci.ege.edu.tr').last);
    await tester.pumpAndSettle();

    expect(selected, 'ogrenci.ege.edu.tr');
  });

  testWidgets('locked mode (onChanged null) shows fixed text, no dropdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DomainSuffixField(
            value: 'ogrenci.ege.edu.tr',
            options: const ['ogrenci.ege.edu.tr'],
            onChanged: null,
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.text('ogrenci.ege.edu.tr'), findsOneWidget);
  });
}
