// Theme: Language.Casting. Positive explicit float to int cast.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
// Oracle: int(5.5f) is 5; int(0.0f) is 0; int(-1.9f) toward-zero is -1.
// Extra: zero default and negative truncation boundary. DefaultSafe.

void Test()
{
	float X = 5.5f;
	int Y = int(X);
}

int Observe_ExplicitFloatToInt_Nominal()
{
	float X = 5.5f;
	int Y = int(X);
	return Y;
}

int Observe_ExplicitFloatToInt_ZeroDefault()
{
	float X = 0.0f;
	return int(X);
}

int Observe_ExplicitFloatToInt_NegativeBoundary()
{
	float X = -1.9f;
	return int(X);
}
