using System;
using System.Collections.Generic;

namespace Examples.CSharp
{
    public record OrderRecord(string Id, string Customer, decimal Amount, string Currency);

    public class ArgumentCounting
    {
        public ArgumentCounting(string a, string b, string c, string d)
        {
        }

        // Not flagged: 3 real parameters, the generic adds a comma
        public void GenericThree(Dictionary<string, string> map, int a, int b)
        {
        }

        // Not flagged: nested generics must not inflate the count
        public void NestedGenerics(Func<int, string, bool> func, IReadOnlyDictionary<string, List<int>> map)
        {
        }

        // Not flagged: tuple parameter has a single real parameter
        public void TupleParameter((int a, int b) pair, string name)
        {
        }

        // Not flagged: 3 params with a tuple return type
        public (int, int) TupleReturn(int a, (int x, int y) b, string c)
        {
            return (a, b.x);
        }

        // Flagged: 4 real parameters including a generic
        public void FourWithGeneric(Dictionary<string, string> map, int a, int b, int c)
        {
        }

        // Flagged: 4 real parameters
        public int FourPlain(int a, int b, int c, int d)
        {
            return a + b + c + d;
        }
    }
}
