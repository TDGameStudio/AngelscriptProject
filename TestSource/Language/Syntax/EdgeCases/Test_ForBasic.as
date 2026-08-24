// Theme: Language.Syntax.EdgeCases. Positive basic for-loop shapes.
// C++: AngelscriptCoverageLoopTests.cpp::ForBasic ExpectGlobalReturn
// sha256=956808bcf89b204130ccf5071b50d64eef4e5cbd6c1c7797c8daebda41cba9b7; lines 73-126.
// Oracle: ForCountUp()==45; ForCountDown()==55; ForStepTwo()==20; ForEmptyBody()==5; ForMultipleVars()==50.
// Extra: ForCountUp-style I<0 yields 0; ForMultipleVars is already the comma-clause vector.
// DefaultSafe. Source owns locals.

int ForCountUp()
{
	int Sum = 0;
	for (int i = 0; i < 10; i++)
	{
		Sum += i;
	}
	return Sum;
}

int ForCountDown()
{
	int Sum = 0;
	for (int i = 10; i >= 0; i--)
	{
		Sum += i;
	}
	return Sum;
}

int ForStepTwo()
{
	int Sum = 0;
	for (int i = 0; i < 10; i += 2)
	{
		Sum += i;
	}
	return Sum;
}

int ForEmptyBody()
{
	int Count = 0;
	for (int i = 0; i < 5; i++)
		Count++;
	return Count;
}

int ForMultipleVars()
{
	int Sum = 0;
	for (int i = 0, j = 10; i < 5; i++, j--)
	{
		Sum += i + j;
	}
	return Sum;
}

bool Observe_ForBasic_Nominal()
{
	return ForCountUp() == 45 && ForCountDown() == 55 && ForStepTwo() == 20 && ForEmptyBody() == 5 && ForMultipleVars() == 50;
}

int Observe_ForBasic_EmptyBound()
{
	int Sum = 0;
	for (int i = 0; i < 0; i++)
	{
		Sum += i;
	}
	return Sum;
}
