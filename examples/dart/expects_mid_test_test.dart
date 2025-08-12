import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Test with expects in the middle', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));

    expect(find.text('1'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'test');

    expect(find.text('test'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
  });
}
