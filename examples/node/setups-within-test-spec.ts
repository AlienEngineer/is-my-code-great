describe('TestClass', () => {
  const mockDependency = jest.fn();

  it('Test1', () => {
    mockDependency.mockReturnValue(true);

    // Act
    const r = doSomething();

    // Assert
    expect(r).toBe(true);
  });

  it('Test2', () => {
    mockDependency.mockReturnValue(false);

    // Act
    const r = doSomething();

    // Assert
    expect(r).toBe(false);
  });
});

function doSomething() {
  return true;
}
