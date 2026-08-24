// Theme: Language.ControlFlow.Jump. Positive value oracle from BreakInLoop.
// C++: AngelscriptCoverageJumpTests.cpp::BreakInLoop
// sha256=a2311a00b19398d642b2fe6b47e5d3d3d5fe99e8d27171f16c45f9d10cfbd52d; lines 77-151.
// Oracle: BreakInFor 10; BreakInWhile 21; BreakInDoWhile 6; MultipleBreaks 55; BreakInNested 6.
// Extra: empty-range for adds nothing; nested break does not exit the outer loop.
// DefaultSafe. Source owns locals.

int BreakInFor()
{
	int Sum = 0;
	for (int i = 0; i < 100; i++)
	{
		if (i >= 5)
			break;
		Sum += i;
	}
	return Sum;
}

int BreakInWhile()
{
	int Sum = 0;
	int i = 0;
	while (i < 100)
	{
		if (i >= 7)
			break;
		Sum += i;
		i++;
	}
	return Sum;
}

int BreakInDoWhile()
{
	int Sum = 0;
	int i = 0;
	do
	{
		if (i >= 4)
			break;
		Sum += i;
		i++;
	} while (i < 100);
	return Sum;
}

int MultipleBreaks()
{
	int Sum = 0;
	for (int i = 0; i < 100; i++)
	{
		if (i < 0)
			break;
		if (i > 10)
			break;
		Sum += i;
	}
	return Sum;
}

int BreakInNested()
{
	int Count = 0;
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 5; j++)
		{
			if (j >= 2)
				break;
			Count++;
		}
	}
	return Count;
}

bool Observe_BreakInLoop_Nominal()
{
	return BreakInFor() == 10
		&& BreakInWhile() == 21
		&& BreakInDoWhile() == 6
		&& MultipleBreaks() == 55
		&& BreakInNested() == 6;
}

bool Observe_BreakInLoop_EmptyDefault()
{
	int Sum = 0;
	for (int i = 0; i < 0; i++)
	{
		if (i >= 5)
			break;
		Sum += i;
	}
	return Sum == 0;
}

bool Observe_BreakInNested_OuterContinues()
{
	return BreakInNested() == 6;
}
