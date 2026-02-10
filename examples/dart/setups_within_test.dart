import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ISomeDependency {
  bool someMethod() => throw UnimplementedError();
}

class MockISomeDependency extends Mock implements ISomeDependency {}

void main() {
  final _mock = MockISomeDependency();

  test('Test1', () {
    when(_mock.someMethod()).thenReturn(true);

    // Act
    bool r = doSomething();

    // Assert
    expect(r, true);
  });

  test('Test2', () {
    when(_mock.someMethod()).thenReturn(false);

    // Act
    bool r = doSomething();

    // Assert
    expect(r, false);
  });
}

bool doSomething() {
  return true;
}
