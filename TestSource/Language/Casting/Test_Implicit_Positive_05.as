// Theme: Language.Casting. Positive implicit integer literal to float.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
// Oracle: float X = 5 yields 5.0; float X = 0 yields 0.0.
// Extra: zero default. DefaultSafe.

void Test()
{
	float X = 5;
}

float Observe_LiteralToFloat_Nominal()
{
	float X = 5;
	return X;
}

float Observe_LiteralToFloat_ZeroDefault()
{
	float X = 0;
	return X;
}
