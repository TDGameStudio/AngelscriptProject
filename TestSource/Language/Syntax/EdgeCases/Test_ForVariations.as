// Theme: Language.Syntax.EdgeCases. Positive for-loops with omitted clauses.
// C++: AngelscriptCoverageLoopTests.cpp::ForVariations ExpectGlobalReturn
// sha256=b572a173092022e719035f45e35e16bc9bddabc2d167e96092d4847988e554a8; lines 150-215.
// Oracle: ForNoInit()==10; ForNoCondition()==10; ForNoIncrement()==10; ForAllEmpty()==3; ForDecrementStep()==77.
// Extra: ForAllEmpty already covers empty clauses; zero-trip uses ForNoInit's i starting at 5.
// DefaultSafe. Source owns locals.

int ForNoInit()
{
	int i = 0;
	int Sum = 0;
	for (; i < 5; i++)
	{
		Sum += i;
	}
	return Sum;
}

int ForNoCondition()
{
	int Sum = 0;
	int i = 0;
	for (;;)
	{
		Sum += i;
		i++;
		if (i >= 5)
			break;
	}
	return Sum;
}

int ForNoIncrement()
{
	int Sum = 0;
	for (int i = 0; i < 5;)
	{
		Sum += i;
		i++;
	}
	return Sum;
}

int ForAllEmpty()
{
	int Sum = 0;
	int i = 0;
	for (;;)
	{
		Sum += i;
		i++;
		if (i >= 3)
			break;
	}
	return Sum;
}

int ForDecrementStep()
{
	int Sum = 0;
	for (int i = 20; i > 0; i -= 3)
	{
		Sum += i;
	}
	return Sum;
}

bool Observe_ForVariations_Nominal()
{
	return ForNoInit() == 10 && ForNoCondition() == 10 && ForNoIncrement() == 10 && ForAllEmpty() == 3 && ForDecrementStep() == 77;
}

int Observe_ForVariations_AlreadySatisfied()
{
	int i = 5;
	int Sum = 0;
	for (; i < 5; i++)
	{
		Sum += i;
	}
	return Sum;
}
