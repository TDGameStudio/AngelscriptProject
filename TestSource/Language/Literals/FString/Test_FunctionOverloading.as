// Theme: Language.Literals.FString. Positive Process overloads FString/FName/FText.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionOverloading
// sha256 from TS-LANG-0147; lines 604-634.
// Oracle: CallProcessString "String: Test"; CallProcessName "Name: Test"; CallProcessText "Text: Test".
// Extra: empty FString overload; FName n"" is NAME_None string.
// DefaultSafe. Source owns locals.

FString Process(FString x)
{
	return "String: " + x;
}

FString Process(FName x)
{
	return "Name: " + x.ToString();
}

FString Process(FText x)
{
	return "Text: " + x.ToString();
}

FString CallProcessString()
{
	return Process("Test");
}

FString CallProcessName()
{
	return Process(n"Test");
}

FString CallProcessText()
{
	return Process(FText::FromString("Test"));
}

bool Observe_FunctionOverloading_Nominal()
{
	return CallProcessString() == "String: Test"
		&& CallProcessName() == "Name: Test"
		&& CallProcessText() == "Text: Test";
}

bool Observe_ProcessString_EmptyDefault()
{
	return Process("") == "String: ";
}

bool Observe_ProcessText_EmptyBoundary()
{
	FText Empty;
	return Process(Empty) == "Text: ";
}
