
    [TestClass]
    public class TestClass
    {
        [TestMethod]
        public void Test1(string x1)
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }

        [TestMethod]
        public void Test2(string x2)
        {
            // Act
            bool r = doSomething();

            // Assert
            Assert.AreEqual(result, r);
        }
    }
