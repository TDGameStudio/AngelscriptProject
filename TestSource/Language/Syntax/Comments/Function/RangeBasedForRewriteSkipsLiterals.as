/**
 * A range-based for loop whose text also appears inside a string literal, a
 * line comment and a block comment. The rewrite must skip all three copies and
 * transform only the real loop, so the sum still reflects the real elements.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.RangeBasedForRewriteSkipsLiterals
 * @Harness Function
 * @Tag Language.Syntax.Comments.RangeBasedForRewriteSkipsLiterals
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerRangeForTests.cpp::RangeBasedForRewriteSkipsStringAndCommentLiterals
 * @Provenance sha256=801f83bc382638593f03f4c20ffce3ba1f409341ce6132b652c03dfe5b6bb99f; lines 119-141.
 * @Provenance Oracle: Entry() == 42 (20+22). Literal mismatch would return 10.
 * @Provenance Extra: empty TArray sums to 0 if the loop body ran on it; Entry stays 42. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Sums a real range-for loop while decoy copies sit in a string and two
	 * comment forms.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs the values 20 and 22
	 * @Return 42, or 10 if the string literal was mangled
	 */
	int Entry()
	{
		TArray<int> Values;
		Values.Add(20);
		Values.Add(22);

		FString LoopText = "for (const int Value : Values)";
		// for (const int Value : Values)
		/* for (const int Value : Values) */

		int Sum = 0;
		for (const int Value : Values)
		{
			Sum += Value;
		}

		if (LoopText != "for (const int Value : Values)")
		{
			return 10;
		}

		return Sum;
	}

	/**
	 * Observe that only the real loop was rewritten.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Entry()
	 * @Return true when the sum is 42
	 */
	UFUNCTION()
	bool RangeForRewriteSkipsDecoyCopies()
	{
		return Entry() == 42;
	}

	/**
	 * Observe the empty-array boundary alongside the nominal value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs an empty array summed by a range-for, then Entry()
	 * @Return true when the empty sum is 0 and Entry still reports 42
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool RangeForRewriteEmptyArrayBoundary()
	{
		TArray<int> Empty;
		int Sum = 0;
		for (const int Value : Empty)
		{
			Sum += Value;
		}

		if (Sum != 0)
		{
			return false;
		}

		return Entry() == 42;
	}
}
