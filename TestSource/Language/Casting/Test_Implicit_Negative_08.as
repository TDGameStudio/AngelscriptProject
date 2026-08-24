// Theme: Language.Casting. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): int64 to int compiles.
// CSV NegativeDiagnostic is wrong; this is a narrowing value oracle.
// Oracle: 0 narrows to 0; 42 fits in int; Test() keeps 999999999999 as the overflow body.
// Extra: zero default and in-range boundary. DefaultSafe.

void Test()
{
	int64 X = 999999999999;
	int Y = X;
}

int Observe_ImplicitInt64ToInt_ZeroDefault()
{
	int64 X = 0;
	int Y = X;
	return Y;
}

int Observe_ImplicitInt64ToInt_FitsBoundary()
{
	int64 X = 42;
	int Y = X;
	return Y;
}

int Observe_ImplicitInt64ToInt_OverflowPayload()
{
	int64 X = 999999999999;
	int Y = X;
	return Y;
}
