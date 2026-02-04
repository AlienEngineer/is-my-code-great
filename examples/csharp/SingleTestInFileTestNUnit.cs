using NUnit.Framework;

namespace SingleTestInFileTestNUnit
{
    [TestFixture]
    public class TestClass
    {
        [Test]
        public void Test1()
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }

        [Test]
        public void Test2()
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }
    }
}
