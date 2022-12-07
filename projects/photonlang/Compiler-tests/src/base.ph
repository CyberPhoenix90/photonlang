import { TestClass, TestMethod, TestInitialize, Assert } from 'Microsoft/VisualStudio/TestTools/UnitTesting';

@TestClass()
export class TestExample {
    @TestInitialize()
    public TestInitialize(): void {
        // Add test initialization code
    }

    @TestMethod()
    public TestMethod1(): void {
        Assert.AreEqual(1, 1);
    }
}
