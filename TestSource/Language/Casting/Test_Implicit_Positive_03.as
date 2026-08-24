// Theme: Language.Casting. Positive implicit uint8 to int widening.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
// Oracle: 5 widens to 5; 0 widens to 0; 255 widens to 255.
// Extra: zero default and max-uint8 boundary. DefaultSafe.

void Test()
{
	uint8 X = 5;
	int Y = X;
}

int Observe_Uint8ToInt_Nominal()
{
	uint8 X = 5;
	int Y = X;
	return Y;
}

int Observe_Uint8ToInt_ZeroDefault()
{
	uint8 X = 0;
	int Y = X;
	return Y;
}

int Observe_Uint8ToInt_MaxBoundary()
{
	uint8 X = 255;
	int Y = X;
	return Y;
}
