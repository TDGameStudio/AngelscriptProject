/**
 * Nested for-loops: a double nest summing a table, a triple nest counting
 * iterations, and a nested range-for over arrays built inside the outer loop.
 * The observers confirm each total plus the empty-outer boundary.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForNestedLoops
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ForNestedLoops
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageLoopTests.cpp::ForNested ExpectGlobalReturn
 * @Provenance sha256=3094171a159471c8b50c693bb33dff19143c21452108332f15aa67878d20d5d9; lines 435-488.
 * @Provenance Oracle: NestedFor()==99; TripleNested()==8; NestedWithArrays()==66.
 * @Provenance Extra: NestedWithArrays empty outer yields 0; TripleNested is the 2x2x2 count boundary.
 * @Provenance DefaultSafe. Source owns locals and inner TArray.
 */

namespace SyntaxTest
{
	/**
	 * Sums a three-by-three table through a double nest.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 99
	 */
	int NestedFor()
	{
		int Sum = 0;
		for (int i = 0; i < 3; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				Sum += i * 10 + j;
			}
		}
		return Sum;
	}

	/**
	 * Counts iterations of a two-by-two-by-two triple nest.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 8
	 */
	int TripleNested()
	{
		int Count = 0;
		for (int i = 0; i < 2; i++)
		{
			for (int j = 0; j < 2; j++)
			{
				for (int k = 0; k < 2; k++)
				{
					Count++;
				}
			}
		}
		return Count;
	}

	/**
	 * Sums a nested range-for with the inner array built per iteration.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 66
	 */
	int NestedWithArrays()
	{
		TArray<int> Outer;
		Outer.Add(1);
		Outer.Add(2);

		int Sum = 0;
		for (int Val1 : Outer)
		{
			TArray<int> Inner;
			Inner.Add(10);
			Inner.Add(20);

			for (int Val2 : Inner)
			{
				Sum += Val1 + Val2;
			}
		}
		return Sum;
	}

	/**
	 * Observe that all three nesting forms produce their totals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all three helpers
	 * @Return true when all three totals match
	 */
	UFUNCTION()
	bool ForNestedNominal()
	{
		if (NestedFor() != 99)
		{
			return false;
		}

		if (TripleNested() != 8)
		{
			return false;
		}

		return NestedWithArrays() == 66;
	}

	/**
	 * Observe that an empty outer array sums nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a range-for over an empty array
	 * @Return 0
	 * @Boundary empty outer
	 */
	UFUNCTION()
	int ForNestedEmptyOuter()
	{
		TArray<int> Outer;
		int Sum = 0;
		for (int Val1 : Outer)
		{
			Sum += Val1;
		}
		return Sum;
	}
}
