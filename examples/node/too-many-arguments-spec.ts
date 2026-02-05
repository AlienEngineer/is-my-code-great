import { describe, it, expect } from '@jest/globals';

describe('TooManyArguments', () => {
  it('function with too many arguments', () => {
    const result = calculateComplexValue(10, 20, 30, 40, 50);
    expect(result).toBe(150);
  });

  it('another function with too many arguments', () => {
    const details = formatUserDetails('John', 'Doe', 'john@example.com', '555-1234', '123 Main St', 'Springfield');
    expect(details).toContain('John');
  });

  it('arrow function with many parameters', () => {
    const processOrder = (orderId: string, customerId: string, amount: number, currency: string, shippingAddress: string, billingAddress: string, paymentMethod: string, isExpress: boolean) => {
      // Function with 8 parameters - significantly too many
    };
    expect(true).toBe(true);
  });
});

function calculateComplexValue(a: number, b: number, c: number, d: number, e: number): number {
  return a + b + c + d + e;
}

function formatUserDetails(firstName: string, lastName: string, email: string, phone: string, address: string, city: string): string {
  return `${firstName} ${lastName}, ${email}, ${phone}, ${address}, ${city}`;
}
