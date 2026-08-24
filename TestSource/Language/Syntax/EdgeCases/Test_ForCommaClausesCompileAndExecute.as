// Theme: Language.Syntax.EdgeCases. Positive for-init/update comma clauses.
// C++: AngelscriptCoverageSpecialControlFlowTests.cpp::ForCommaClausesCompileAndExecute
// sha256=49752852e6dde5b62a404379ff751ae82e9360be8abc43475a0c100f075de768; lines 146-156.
// Oracle: ForCommaClauses()==50.
// Extra: i<0 empty trip yields 0; i<1 single trip is 0+10=10.
// DefaultSafe. Source owns locals.

int ForCommaClauses()
{
	int Sum = 0;
	for (int i = 0, j = 10; i < 5; i++, j--)
	{
		Sum += i + j;
	}
	return Sum;
}

bool Observe_ForCommaClauses_Nominal()
{
	return ForCommaClauses() == 50;
}

int Observe_ForCommaClauses_EmptyBound()
{
	int Sum = 0;
	for (int i = 0, j = 10; i < 0; i++, j--)
	{
		Sum += i + j;
	}
	return Sum;
}

int Observe_ForCommaClauses_SingleTrip()
{
	int Sum = 0;
	for (int i = 0, j = 10; i < 1; i++, j--)
	{
		Sum += i + j;
	}
	return Sum;
}
