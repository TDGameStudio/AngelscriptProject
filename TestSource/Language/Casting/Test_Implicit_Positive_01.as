// Theme: Language.Casting. Positive implicit int to float.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
// Oracle: 5 widens to 5.0; 0 widens to 0.0; -1 widens to -1.0.
// Extra: zero default and negative boundary. DefaultSafe.

void Test()
{
	int X = 5;
	float Y = X;
}

float Observe_IntToFloat_Nominal()
{
	int X = 5;
	float Y = X;
	return Y;
}

float Observe_IntToFloat_ZeroDefault()
{
	int X = 0;
	float Y = X;
	return Y;
}

float Observe_IntToFloat_NegativeBoundary()
{
	int X = -1;
	float Y = X;
	return Y;
}
