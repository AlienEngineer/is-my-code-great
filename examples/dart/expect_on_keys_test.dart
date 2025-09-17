import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/widgets/login_form.dart';

void main() {
  testWidgets('Test with expect on keys', (tester) async {
    await tester.pumpWidget(const LoginForm());

    expect(find.byKey(const Key('username_field')), findsOneWidget);
    expect(find.byKey(const Key('submit_button')), findsOneWidget);
    expect(find.byKey(const Key('success_message')), findsOneWidget);
  });
} 
