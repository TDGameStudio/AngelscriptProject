// Theme: Language.Casting. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): bool to int compiles.
// CSV NegativeDiagnostic is wrong; this is a 1/0 value oracle.
// Oracle: true widens to 1; false widens to 0.
// Extra: false is the empty/default vector. DefaultSafe.

void Test()
{
	bool B = true;
	int X = B;
}

int Observe_ImplicitBoolToInt_True()
{
	bool B = true;
	int X = B;
	return X;
}

int Observe_ImplicitBoolToInt_FalseDefault()
{
	bool B = false;
	int X = B;
	return X;
}
