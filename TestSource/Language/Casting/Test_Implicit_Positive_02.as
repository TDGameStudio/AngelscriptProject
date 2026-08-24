// Theme: Language.Casting. Positive implicit int to int64 widening.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
// Oracle: 5 widens to 5; 0 widens to 0; -1 widens to -1.
// Extra: zero default and negative boundary. DefaultSafe.

void Test()
{
	int X = 5;
	int64 Y = X;
}

int64 Observe_IntToInt64_Nominal()
{
	int X = 5;
	int64 Y = X;
	return Y;
}

int64 Observe_IntToInt64_ZeroDefault()
{
	int X = 0;
	int64 Y = X;
	return Y;
}

int64 Observe_IntToInt64_NegativeBoundary()
{
	int X = -1;
	int64 Y = X;
	return Y;
}
