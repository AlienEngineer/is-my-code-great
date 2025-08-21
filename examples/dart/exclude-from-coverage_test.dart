// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';


void main() {
  testWidgets('Big test function with many lines', (tester) async {
    await tester.pumpWidget(const MyApp());

    // coverage:ignore-line
    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
