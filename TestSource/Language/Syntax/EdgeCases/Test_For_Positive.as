// Theme: Language.Syntax.EdgeCases. Positive for-loop syntax cases from SyntaxControlFlow.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Positive ExpectGlobalInts
// sha256=8afd93a8a158de22433f2bb2762dfc17cc57e83a68488307d89245bbeda083f9; lines 139-145.
// Oracle: BasicFor 10; Decrement 6; Empty 3; Nested 6; CompoundStep 4.
// Extra: for I<0 yields 0; CompoundStep is the step-boundary vector.
// DefaultSafe. Source owns locals.

int BasicFor()
{
	int S = 0;
	for (int I = 0; I < 5; ++I)
	{
		S += I;
	}
	return S;
}

int Decrement()
{
	int S = 0;
	for (int I = 3; I > 0; --I)
	{
		S += I;
	}
	return S;
}

int Empty()
{
	int I = 0;
	for (;;)
	{
		if (I >= 3)
		{
			break;
		}
		++I;
	}
	return I;
}

int Nested()
{
	int S = 0;
	for (int I = 0; I < 3; ++I)
	{
		for (int J = 0; J < 2; ++J)
		{
			++S;
		}
	}
	return S;
}

int CompoundStep()
{
	int S = 0;
	for (int I = 0; I < 100; I += 25)
	{
		++S;
	}
	return S;
}

bool Observe_ForPositive_Nominal()
{
	return BasicFor() == 10 && Decrement() == 6 && Empty() == 3 && Nested() == 6 && CompoundStep() == 4;
}

int Observe_ForPositive_EmptyBound()
{
	int S = 0;
	for (int I = 0; I < 0; ++I)
	{
		S += I;
	}
	return S;
}
