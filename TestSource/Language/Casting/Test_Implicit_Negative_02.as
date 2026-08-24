// Theme: Language.Casting. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): float to int compiles.
// CSV NegativeDiagnostic is wrong; this is a truncation value oracle.
// Oracle: 5.5f implicit-narrows to 5; 0.0f to 0; -1.9f toward-zero to -1.
// Extra: zero default and negative truncation boundary. DefaultSafe.

void Test()
{
	float X = 5.5f;
	int Y = X;
}

int Observe_ImplicitFloatToInt_Nominal()
{
	float X = 5.5f;
	int Y = X;
	return Y;
}

int Observe_ImplicitFloatToInt_ZeroDefault()
{
	float X = 0.0f;
	int Y = X;
	return Y;
}

int Observe_ImplicitFloatToInt_NegativeBoundary()
{
	float X = -1.9f;
	int Y = X;
	return Y;
}
