// Theme: Language.Syntax.EdgeCases. Positive combined break/continue/return in for-loops.
// C++: AngelscriptCoverageJumpTests.cpp::CombinedJumps ExpectGlobalReturn
// sha256=d1a84342665b4ca19e3d04eac5dff53ee19ee9d79dc7664363a115148fb8fbc0; lines 564-618.
// Oracle: BreakAndContinue()==64; AllThreeJumps(800)==817; NestedVariousJumps()==12.
// Extra: AllThreeJumps(0)==1 zero-limit early return; BreakAndContinue still 64 on a fresh call.
// DefaultSafe. Source owns locals.

int BreakAndContinue()
{
	int Sum = 0;
	for (int i = 0; i < 20; i++)
	{
		if (i > 15)
			break;
		if (i % 2 == 0)
			continue;
		Sum += i;
	}
	return Sum;
}

int AllThreeJumps(int Limit)
{
	int Sum = 0;
	for (int i = 0; i < 100; i++)
	{
		if (Sum > Limit)
			return Sum;
		if (i > 50)
			break;
		if (i % 3 == 0)
			continue;
		Sum += i;
	}
	return Sum;
}

int NestedVariousJumps()
{
	int Count = 0;
	for (int i = 0; i < 5; i++)
	{
		if (i == 0)
			continue;
		for (int j = 0; j < 5; j++)
		{
			if (j == 2)
				continue;
			if (j == 4)
				break;
			Count++;
		}
		if (Count > 10)
			return Count;
	}
	return Count;
}

bool Observe_CombinedJumps_Nominal()
{
	return BreakAndContinue() == 64 && AllThreeJumps(800) == 817 && NestedVariousJumps() == 12;
}

int Observe_CombinedJumps_ZeroLimit()
{
	return AllThreeJumps(0);
}
