import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Big test function with many lines', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.longPress(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.text('0'), findsOneWidget);
  });

  test('Some other test', () {
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
  });

  testGoldens('bla bla bla', (tester) async {
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
  });

  testWidgets('some test name', (tester) async {
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    // some golden test here
    await tester.runAsync(() async {
      someBuilder.build((context) {
        return Container();
      });
    });
  });
}
