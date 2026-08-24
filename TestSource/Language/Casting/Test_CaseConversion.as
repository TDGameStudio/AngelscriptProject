// Theme: Language.Casting. Positive value oracle from CaseConversion.
// C++: AngelscriptCoverageFStringMethodTests.cpp::CaseConversion
// Oracle: TestToUpper "HELLO WORLD"; TestToLower "hello world"; mixed ToUpper "HELLO WORLD".
// Extra: empty string stays empty; already-upper ToUpper is idempotent.
// DefaultSafe. Source owns locals.

FString TestToUpper()
{
	FString s = "hello world";
	return s.ToUpper();
}

FString TestToLower()
{
	FString s = "HELLO WORLD";
	return s.ToLower();
}

FString TestToUpperMixed()
{
	FString s = "HeLLo WoRLd";
	return s.ToUpper();
}

bool Observe_CaseConversion_Nominal()
{
	return TestToUpper() == "HELLO WORLD" && TestToLower() == "hello world" && TestToUpperMixed() == "HELLO WORLD";
}

bool Observe_CaseConversion_EmptyDefault()
{
	FString Empty;
	return Empty.ToUpper().Len() == 0 && Empty.ToLower().Len() == 0;
}

bool Observe_CaseConversion_AlreadyUpperBoundary()
{
	FString Upper = "HELLO WORLD";
	return Upper.ToUpper() == "HELLO WORLD";
}
