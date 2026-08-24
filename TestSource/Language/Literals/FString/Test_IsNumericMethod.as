// Theme: Language.Literals.FString. C++ ExpectGlobalReturn on IsNumeric; CSV NegativeDiagnostic
// is a heuristic. This file is a value oracle, not a compile-fail.
// C++: AngelscriptCoverageFStringMethodTests.cpp::IsNumericMethod
// sha256=51f797d87633a37da7320fb70701db4658d92aea0caaf3cbe840c8d3356b205a; lines 1000-1024.
// Oracle: TestIsNumeric_True true; TestIsNumeric_False false; TestIsNumeric_Negative true; TestIsNumeric_Float true.
// Extra: empty IsNumeric false; leading space is not numeric.
// DefaultSafe. Source owns locals.

bool TestIsNumeric_True()
{
	FString s = "12345";
	return s.IsNumeric();
}

bool TestIsNumeric_False()
{
	FString s = "Hello123";
	return s.IsNumeric();
}

bool TestIsNumeric_Negative()
{
	FString s = "-456";
	return s.IsNumeric();
}

bool TestIsNumeric_Float()
{
	FString s = "3.14";
	return s.IsNumeric();
}

bool Observe_IsNumeric_Nominal()
{
	return TestIsNumeric_True() && !TestIsNumeric_False() && TestIsNumeric_Negative() && TestIsNumeric_Float();
}

bool Observe_IsNumeric_EmptyDefault()
{
	FString Empty;
	return !Empty.IsNumeric();
}

bool Observe_IsNumeric_WhitespaceBoundary()
{
	FString s = " 123";
	return !s.IsNumeric();
}
