import 'package:test/test.dart';

void main() {
  group('TooManyArguments', () {
    test('method with too many arguments', () {
      final result = calculateComplexValue(10, 20, 30, 40, 50);
      expect(result, equals(150));
    });

    test('another method with too many arguments', () {
      final details = formatUserDetails('John', 'Doe', 'john@example.com', '555-1234', '123 Main St', 'Springfield');
      expect(details, contains('John'));
    });

    test('yet another method with many parameters', () {
      processOrder('ORD123', 'CUST456', 99.99, 'USD', '123 Main St', '456 Oak Ave', 'credit_card', true);
      expect(true, isTrue);
    });
  });
}

int calculateComplexValue(int a, int b, int c, int d, int e) {
  return a + b + c + d + e;
}

String formatUserDetails(String firstName, String lastName, String email, String phone, String address, String city) {
  return '$firstName $lastName, $email, $phone, $address, $city';
}

void processOrder(String orderId, String customerId, double amount, String currency, String shippingAddress, String billingAddress, String paymentMethod, bool isExpress) {
  // Method with 8 parameters - significantly too many
}
