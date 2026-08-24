// Theme: Language.ControlFlow.If. Positive value oracle from IfElse_Positive.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Positive
// sha256=c3bbf48b9914843b35513ca7dd38db4456299b32fdbfc2a5847315f3bb9ea2b2; lines 49-56.
// Oracle: BasicIf 1; IfElse 2; IfElseIf 2; Nested 1; NoBrace 1; Complex 3.
// Extra: NoBrace else is unreachable here; Complex requires both positives.
// DefaultSafe. Source owns locals.

int BasicIf()
{
	if (true)
	{
		return 1;
	}
	return 0;
}

int IfElse()
{
	if (false)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}

int IfElseIf()
{
	int X = 5;
	if (X > 10)
	{
		return 1;
	}
	else if (X > 3)
	{
		return 2;
	}
	else
	{
		return 3;
	}
}

int Nested()
{
	if (true)
	{
		if (true)
		{
			return 1;
		}
	}
	return 0;
}

int NoBrace()
{
	int X = 0;
	if (true)
		X = 1;
	else
		X = 2;
	return X;
}

int Complex()
{
	int A = 1;
	int B = 2;
	if (A > 0 && B > 0)
	{
		return A + B;
	}
	return 0;
}

bool Observe_IfElse_Positive_Nominal()
{
	return BasicIf() == 1
		&& IfElse() == 2
		&& IfElseIf() == 2
		&& Nested() == 1
		&& NoBrace() == 1
		&& Complex() == 3;
}

bool Observe_IfElse_Positive_FalseElse()
{
	int X = 0;
	if (false)
		X = 1;
	else
		X = 2;
	return X == 2;
}

bool Observe_IfElse_Positive_ZeroBoundary()
{
	int A = 0;
	int B = 2;
	int Result = 0;
	if (A > 0 && B > 0)
	{
		Result = A + B;
	}
	return Result == 0;
}
