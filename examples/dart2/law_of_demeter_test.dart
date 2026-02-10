import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Test that violate law of demeter', (tester) async {
    final result = getResult();

    final data = result.somefield.someotherfield;
  });

  testWidgets('Test that violate law of demeter 2', (tester) async {
    final result = getResult();

    final data = result.somefield.someotherfield.test;
  });
}
