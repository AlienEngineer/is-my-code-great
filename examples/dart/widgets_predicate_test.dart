import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/widgets/custom_widget.dart';

void main() {
  testWidgets('Test with widget predicate', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CustomWidget(title: 'Test Widget'),
      ),
    ));

    expect(
      find.byWidgetPredicate((widget) => widget is CustomWidget && widget.title == 'Test Widget'),
      findsOneWidget
    );

    expect(
      find.byWidgetPredicate((widget) => widget is Text && widget.data?.contains('Test') == true),
      findsAtLeastNWidget(1)
    );

    expect(
      find.byWidgetPredicate((widget) => widget is ElevatedButton),
      findsOneWidget
    );
  });
}
