import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/models/user.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  test('Test with verify method calls', () {
    final mockApiService = MockApiService();
    final user = User(id: 1, name: 'John');

    verify(() => mockApiService.getUser()).called(1);
    verify(() => mockApiService.saveUser(any())).called(1);
    verifyNever(() => mockApiService.deleteUser(any()));
    verify(() => mockApiService.updateUser(user)).called(2);
  });
}
