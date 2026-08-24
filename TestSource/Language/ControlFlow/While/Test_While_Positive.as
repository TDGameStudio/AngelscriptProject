// Theme: Language.ControlFlow.While. Positive while/do-while syntax oracles.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Positive
// sha256=87785a242806794eacb9b610748bdf7f8419c75a5a0dc47130d34c309d7540b3; lines 213-219.
// Oracle: BasicWhile 5; WhileBreak 3; DoWhile 5; DoWhileOnce 42; Nested 6.
// Extra: while(false) leaves I at 0; do-while(false) still assigns.
// DefaultSafe. Source owns locals.

int BasicWhile()
{
	int I = 0;
	while (I < 5)
	{
		++I;
	}
	return I;
}

int WhileBreak()
{
	int I = 0;
	while (true)
	{
		if (I >= 3)
		{
			break;
		}
		++I;
	}
	return I;
}

int DoWhile()
{
	int I = 0;
	do
	{
		++I;
	} while (I < 5);
	return I;
}

int DoWhileOnce()
{
	int X = 0;
	do
	{
		X = 42;
	} while (false);
	return X;
}

int Nested()
{
	int S = 0;
	int I = 0;
	while (I < 3)
	{
		int J = 0;
		while (J < 2)
		{
			++S;
			++J;
		}
		++I;
	}
	return S;
}

bool Observe_While_Positive_Nominal()
{
	return BasicWhile() == 5 && WhileBreak() == 3 && DoWhile() == 5 && DoWhileOnce() == 42 && Nested() == 6;
}

int Observe_While_EmptyFalse()
{
	int I = 0;
	while (false)
	{
		++I;
	}
	return I;
}

int Observe_DoWhile_FalseStillAssigns()
{
	int X = 0;
	do
	{
		X = 42;
	} while (false);
	return X;
}
