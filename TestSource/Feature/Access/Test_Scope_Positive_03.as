// Theme: Feature.Access. Positive: loop variables are isolated per for-loop.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Positive block 3 AssertCompiles.
// Oracle: first loop Last==4; second empty loop does not reuse I; zero-iteration keeps marker.
// Extra: empty second loop; I < 0 boundary leaves Marker==7.
// DefaultSafe.

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		int X = I;
	}
	for (int I = 0; I < 3; ++I)
	{
	}
}

int Observe_LoopVarLastValue()
{
	int Last = -1;
	for (int I = 0; I < 5; ++I)
	{
		int X = I;
		Last = X;
	}
	return Last;
}

int Observe_EmptySecondLoopDefault()
{
	int Count = 0;
	for (int I = 0; I < 3; ++I)
	{
	}
	return Count;
}

int Observe_ZeroIterationBoundary()
{
	int Marker = 7;
	for (int I = 0; I < 0; ++I)
	{
		Marker = 0;
	}
	return Marker;
}
