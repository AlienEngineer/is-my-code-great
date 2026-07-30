import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Test with find byIcon', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Test with find text', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('1'), findsOneWidget);
  });
}
