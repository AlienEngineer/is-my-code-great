using Xunit;

namespace Examples.CSharp
{
    public class TooManyArgumentsTest
    {
        [Fact]
        public void TestMethodWithTooManyArguments()
        {
            var result = CalculateComplexValue(10, 20, 30, 40, 50);
            Assert.Equal(150, result);
        }

        private int CalculateComplexValue(int a, int b, int c, int d, int e)
        {
            return a + b + c + d + e;
        }

        public string FormatUserDetails(string firstName, string lastName, string email, string phone, string address, string city)
        {
            return $"{firstName} {lastName}, {email}, {phone}, {address}, {city}";
        }

        public void ProcessOrder(string orderId, string customerId, decimal amount, string currency, string shippingAddress, string billingAddress, string paymentMethod, bool isExpress)
        {
            // Method with 8 parameters - significantly too many
        }
    }
}
