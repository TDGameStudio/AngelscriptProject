// Theme: Language.ControlFlow.While. Positive while, nested, continue, break.
// C++: AngelscriptCoverageLoopTests.cpp::WhileBasic
// sha256=0b45b474e80687259e86a10efadce99dc35b20890cbf48d2703979ec52400f40; lines 510-584.
// Oracle: BasicWhile 10; WhileComplexCondition 21; WhileInfinite 10; NestedWhile 9; WhileWithContinue 25.
// Extra: while(false) leaves sum 0; continue-only-evens already in WhileWithContinue.
// DefaultSafe. Source owns locals.

int BasicWhile()
{
	int Sum = 0;
	int i = 0;
	while (i < 5)
	{
		Sum += i;
		i++;
	}
	return Sum;
}

int WhileComplexCondition()
{
	int Sum = 0;
	int i = 0;
	while (i < 10 && Sum < 20)
	{
		Sum += i;
		i++;
	}
	return Sum;
}

int WhileInfinite()
{
	int Sum = 0;
	int i = 0;
	while (true)
	{
		Sum += i;
		i++;
		if (i >= 5)
		{
			break;
		}
	}
	return Sum;
}

int NestedWhile()
{
	int Sum = 0;
	int i = 0;
	while (i < 3)
	{
		int j = 0;
		while (j < 2)
		{
			Sum += i + j;
			j++;
		}
		i++;
	}
	return Sum;
}

int WhileWithContinue()
{
	int Sum = 0;
	int i = 0;
	while (i < 10)
	{
		i++;
		if (i % 2 == 0)
		{
			continue;
		}
		Sum += i;
	}
	return Sum;
}

bool Observe_WhileBasic_Nominal()
{
	return BasicWhile() == 10 && WhileComplexCondition() == 21 && WhileInfinite() == 10 && NestedWhile() == 9 && WhileWithContinue() == 25;
}

int Observe_While_EmptyFalse()
{
	int Sum = 0;
	int i = 0;
	while (false)
	{
		Sum += i;
		i++;
	}
	return Sum;
}

int Observe_While_ZeroBound()
{
	int Sum = 0;
	int i = 0;
	while (i < 0)
	{
		Sum += i;
		i++;
	}
	return Sum;
}
