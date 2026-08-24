// Theme: Language.Casting. Positive explicit int to uint8 narrowing.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
// Oracle: uint8(300) wraps to 44; uint8(0) is 0; uint8(255) stays 255.
// Extra: zero default and max-uint8 boundary. DefaultSafe.

void Test()
{
	int X = 300;
	uint8 Y = uint8(X);
}

uint8 Observe_ExplicitIntToUint8_Nominal()
{
	int X = 300;
	uint8 Y = uint8(X);
	return Y;
}

uint8 Observe_ExplicitIntToUint8_ZeroDefault()
{
	return uint8(0);
}

uint8 Observe_ExplicitIntToUint8_MaxBoundary()
{
	return uint8(255);
}
