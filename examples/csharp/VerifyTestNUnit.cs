using NUnit.Framework;
using Moq;

namespace VerifyTestNUnit
{
    [TestFixture]
    public class TestClass
    {
        [Test]
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

        [Test]
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
