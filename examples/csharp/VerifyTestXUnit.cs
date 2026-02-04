using Xunit;
using Moq;

namespace VerifyTestXUnit
{
    public class TestClass
    {
        [Fact]
        public void My_test1()
        {
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            somevariable.Verify(
                x => x.somemethod()
            );
        }

        [Fact]
        public void My_test1()
        {
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
            // This is my test
        }
    }
}
