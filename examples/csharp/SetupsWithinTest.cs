
    [TestClass]
    public class TestClass
    {
        private readonly Mock<ISomeDependency> _mock = new Mock<ISomeDependency>();

        [TestMethod]
        public void Test1()
        {
            _mock.Setup(m => m.SomeMethod()).Returns(true);

            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }

        [TestMethod]
        public void Test2()
        {
            _mock.Setup(m => m.SomeMethod()).Returns(false);

            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }
    }
