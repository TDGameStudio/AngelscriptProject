// Theme: Language.ControlFlow.If. Positive value oracle from IfBasic.
// C++: AngelscriptCoverageConditionalTests.cpp::IfBasic
// sha256=c21d26b5495e59f8a697601a26b9c38bb9c47300d04f717579f4441aa5b08214; lines 79-151.
// Oracle: SimpleIf(true) 10; IfElse(true) 1; IfElseIf(5) 1; IfElseIfElse(15) 2; SingleLineIf(true) 5.
// Extra: false/zero/else branches; SingleLineIf(false) stays 0.
// DefaultSafe. Source owns locals.

int SimpleIf(bool Condition)
{
	int Result = 0;
	if (Condition)
	{
		Result = 10;
	}
	return Result;
}

int IfElse(bool Condition)
{
	if (Condition)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}

int IfElseIf(int Value)
{
	if (Value < 0)
	{
		return -1;
	}
	else if (Value > 0)
	{
		return 1;
	}
	else if (Value == 0)
	{
		return 0;
	}
	return 999;
}

int IfElseIfElse(int Value)
{
	if (Value < 10)
	{
		return 1;
	}
	else if (Value < 20)
	{
		return 2;
	}
	else if (Value < 30)
	{
		return 3;
	}
	else
	{
		return 4;
	}
}

int SingleLineIf(bool Condition)
{
	int Result = 0;
	if (Condition)
		Result = 5;
	return Result;
}

bool Observe_IfBasic_Nominal()
{
	return SimpleIf(true) == 10
		&& IfElse(true) == 1
		&& IfElseIf(5) == 1
		&& IfElseIfElse(15) == 2
		&& SingleLineIf(true) == 5;
}

bool Observe_IfBasic_FalseDefault()
{
	return SimpleIf(false) == 0
		&& IfElse(false) == 2
		&& IfElseIf(0) == 0
		&& SingleLineIf(false) == 0;
}

bool Observe_IfBasic_Boundary()
{
	return IfElseIf(-3) == -1
		&& IfElseIfElse(5) == 1
		&& IfElseIfElse(25) == 3
		&& IfElseIfElse(30) == 4;
}
