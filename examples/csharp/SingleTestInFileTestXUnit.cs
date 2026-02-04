using Xunit;

namespace SingleTestInFileTestXUnit
{
    public class TestClass
    {
        [Fact]
        public void Test1()
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.Equal(result, r);
        }

        [Fact]
        public void Test2()
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.Equal(result, r);
        }
    }
}
