// Theme: Language.Casting. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): float to uint8 compiles.
// CSV NegativeDiagnostic is wrong; this is a truncation value oracle.
// Oracle: 3.14f implicit-narrows to 3; 0.0f to 0.
// Extra: zero default. DefaultSafe.

void Test()
{
	float X = 3.14f;
	uint8 Y = X;
}

uint8 Observe_ImplicitFloatToUint8_Nominal()
{
	float X = 3.14f;
	uint8 Y = X;
	return Y;
}

uint8 Observe_ImplicitFloatToUint8_ZeroDefault()
{
	float X = 0.0f;
	uint8 Y = X;
	return Y;
}
