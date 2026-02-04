using Xunit;
using Moq;

namespace SetupsWithinTestXUnit
{
    public class TestClass
    {
        private readonly Mock<ISomeDependency> _mock = new Mock<ISomeDependency>();

        [Fact]
        public void Test1()
        {
            _mock.Setup(m => m.SomeMethod()).Returns(true);

            // Act
            bool r = doSomething();

            // Assert
            Assert.Equal(result, r);
        }

        [Fact]
        public void Test2()
        {
            _mock.Setup(m => m.SomeMethod()).Returns(false);

            // Act
            bool r = doSomething();

            // Assert
            Assert.Equal(result, r);
        }
    }
}
