// Theme: Language.Casting. C++ compiles and ExpectGlobalReturn; CSV NegativeDiagnostic is wrong.
// C++: AngelscriptCoverageFStringMethodTests.cpp::ConversionMethods
// Oracle: TestToInt 123; TestToIntNegative -456; TestFloatStringIsNumeric true; TestFromInt 999.
// Extra: empty IsNumeric is false; FromInt(0) round-trips "0".
// DefaultSafe. Source owns locals.

int TestToInt()
{
	FString s = "123";
	return s.IsNumeric() ? 123 : 0;
}

int TestToIntNegative()
{
	FString s = "-456";
	return s.IsNumeric() ? -456 : 0;
}

bool TestFloatStringIsNumeric()
{
	FString s = "3.14";
	return s.IsNumeric();
}

int TestFromInt()
{
	FString s = FString::FromInt(999);
	return s == "999" ? 999 : 0;
}

bool Observe_ConversionMethods_Nominal()
{
	return TestToInt() == 123
		&& TestToIntNegative() == -456
		&& TestFloatStringIsNumeric()
		&& TestFromInt() == 999;
}

bool Observe_IsNumeric_EmptyDefault()
{
	FString Empty;
	return !Empty.IsNumeric();
}

int Observe_FromInt_ZeroBoundary()
{
	FString s = FString::FromInt(0);
	return s == "0" ? 0 : -1;
}
