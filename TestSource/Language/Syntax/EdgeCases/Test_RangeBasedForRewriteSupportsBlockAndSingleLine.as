// Theme: Language.Syntax.EdgeCases. Positive range-for rewrite for block and single-line bodies.
// C++: AngelscriptCompilerControlFlowTests.cpp::RangeBasedForRewriteSupportsBlockAndSingleLine
// sha256=2f8d4d86b2b1b796d12b2cfb27c5293327e89c61202c442f4198ea3ad02000ae; lines 91-109.
// Oracle: Entry() == 4242 (BlockSum 42 * 100 + SingleLineSum 42). Keep the single-line for as one statement.
// Extra: empty TArray yields 0*100+0. DefaultSafe.

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

bool Observe_Entry_Nominal()
{
	return Entry() == 4242;
}

bool Observe_RangeFor_EmptyDefault()
{
	TArray<int> Empty;
	int BlockSum = 0;
	for (const int Value : Empty)
	{
		BlockSum += Value;
	}
	int SingleLineSum = 0;
	for (const int Value : Empty) SingleLineSum += Value;
	return BlockSum == 0 && SingleLineSum == 0 && Entry() == 4242;
}
