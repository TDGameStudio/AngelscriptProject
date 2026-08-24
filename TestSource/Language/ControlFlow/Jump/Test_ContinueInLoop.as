// Theme: Language.ControlFlow.Jump. Positive value oracle from ContinueInLoop.
// C++: AngelscriptCoverageJumpTests.cpp::ContinueInLoop
// sha256=aca66875b20d794c6101eeafe5d1f2ac4645275ed14619a99f8a914f98dadb80; lines 266-353.
// Oracle: ContinueInFor 25; ContinueInWhile 25; ContinueInDoWhile 37; MultipleContinues 110; ContinueInNested 6; ContinueComplexCondition 64.
// Extra: empty-range for adds nothing; continue skips even values in ContinueInFor.
// DefaultSafe. Source owns locals.

int ContinueInFor()
{
	int Sum = 0;
	for (int i = 0; i < 10; i++)
	{
		if (i % 2 == 0)
			continue;
		Sum += i;
	}
	return Sum;
}

int ContinueInWhile()
{
	int Sum = 0;
	int i = 0;
	while (i < 10)
	{
		i++;
		if (i % 2 == 0)
			continue;
		Sum += i;
	}
	return Sum;
}

int ContinueInDoWhile()
{
	int Sum = 0;
	int i = 0;
	do
	{
		i++;
		if (i % 3 == 0)
			continue;
		Sum += i;
	} while (i < 10);
	return Sum;
}

int MultipleContinues()
{
	int Sum = 0;
	for (int i = 0; i < 20; i++)
	{
		if (i < 5)
			continue;
		if (i > 15)
			continue;
		Sum += i;
	}
	return Sum;
}

int ContinueInNested()
{
	int Count = 0;
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 5; j++)
		{
			if (j % 2 == 0)
				continue;
			Count++;
		}
	}
	return Count;
}

int ContinueComplexCondition()
{
	int Sum = 0;
	for (int i = 0; i < 20; i++)
	{
		if (i % 2 == 0 || i > 15)
			continue;
		Sum += i;
	}
	return Sum;
}

bool Observe_ContinueInLoop_Nominal()
{
	return ContinueInFor() == 25
		&& ContinueInWhile() == 25
		&& ContinueInDoWhile() == 37
		&& MultipleContinues() == 110
		&& ContinueInNested() == 6
		&& ContinueComplexCondition() == 64;
}

bool Observe_ContinueInLoop_EmptyDefault()
{
	int Sum = 0;
	for (int i = 0; i < 0; i++)
	{
		if (i % 2 == 0)
			continue;
		Sum += i;
	}
	return Sum == 0;
}

bool Observe_ContinueInFor_AllEvenSkipped()
{
	return ContinueInFor() == (1 + 3 + 5 + 7 + 9);
}
