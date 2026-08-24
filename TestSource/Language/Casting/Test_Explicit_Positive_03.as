// Theme: Language.Casting. Positive explicit int to float cast.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
// Oracle: float(5) is 5.0; float(0) is 0.0; float(-1) is -1.0.
// Extra: zero default and negative boundary. DefaultSafe.

void Test()
{
	int X = 5;
	float Y = float(X);
}

float Observe_ExplicitIntToFloat_Nominal()
{
	int X = 5;
	float Y = float(X);
	return Y;
}

float Observe_ExplicitIntToFloat_ZeroDefault()
{
	int X = 0;
	return float(X);
}

float Observe_ExplicitIntToFloat_NegativeBoundary()
{
	int X = -1;
	return float(X);
}
