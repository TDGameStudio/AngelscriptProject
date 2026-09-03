/**
 * The range-for rewrite handling both a braced block body and a single-line body
 * without braces. The single-line form must stay one statement; reformatting it
 * into a block would defeat the case.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RangeBasedForRewriteSupportsBlockAndSingleLine
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RangeBasedForRewriteSupportsBlockAndSingleLine
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerControlFlowTests.cpp::RangeBasedForRewriteSupportsBlockAndSingleLine
 * @Provenance sha256=2f8d4d86b2b1b796d12b2cfb27c5293327e89c61202c442f4198ea3ad02000ae; lines 91-109.
 * @Provenance Oracle: Entry() == 4242 (BlockSum 42 * 100 + SingleLineSum 42). Keep the single-line for as one statement.
 * @Provenance Extra: empty TArray yields 0*100+0. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Sums one array through both body forms.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the values 20 and 22
	 * @Return 4242, encoding both sums
	 */
	int Entry()
	{
		TArray<int> Values;
		Values.Add(20);
		Values.Add(22);

		int BlockSum = 0;
		for (const int Value : Values)
		{
			BlockSum += Value;
		}

		int SingleLineSum = 0;
		for (const int Value : Values) SingleLineSum += Value;

		return BlockSum * 100 + SingleLineSum;
	}

	/**
	 * Observe the combined result of both body forms.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 4242
	 */
	UFUNCTION()
	bool EntryNominal()
	{
		return Entry() == 4242;
	}

	/**
	 * Observe the empty-array boundary for both body forms.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an empty array through both body forms
	 * @Return true when both sums are 0 and Entry still reports 4242
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool RangeForEmptyDefault()
	{
		TArray<int> Empty;
		int BlockSum = 0;
		for (const int Value : Empty)
		{
			BlockSum += Value;
		}
		int SingleLineSum = 0;
		for (const int Value : Empty) SingleLineSum += Value;

		if (BlockSum != 0)
		{
			return false;
		}

		if (SingleLineSum != 0)
		{
			return false;
		}

		return Entry() == 4242;
	}
}
