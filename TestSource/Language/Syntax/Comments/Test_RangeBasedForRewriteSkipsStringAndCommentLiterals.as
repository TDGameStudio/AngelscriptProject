// Theme: Language.Syntax.Comments. Positive: range-for rewrite skips string and comment copies of the loop.
// C++: AngelscriptCompilerRangeForTests.cpp::RangeBasedForRewriteSkipsStringAndCommentLiterals
// sha256=801f83bc382638593f03f4c20ffce3ba1f409341ce6132b652c03dfe5b6bb99f; lines 119-141.
// Oracle: Entry() == 42 (20+22). Literal mismatch would return 10.
// Extra: empty TArray sums to 0 if the loop body ran on it; Entry stays 42. DefaultSafe.

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
		return 10;

	return Sum;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 42;
}

bool Observe_Entry_EmptyArrayBoundary()
{
	TArray<int> Empty;
	int Sum = 0;
	for (const int Value : Empty)
	{
		Sum += Value;
	}
	return Sum == 0 && Entry() == 42;
}
