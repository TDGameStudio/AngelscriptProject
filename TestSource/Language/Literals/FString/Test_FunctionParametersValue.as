// Theme: Language.Literals.FString. Positive FString/FName/FText value parameters.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersValue
// sha256=369fb8ae84f1857e1cd6b5dd9c00882c24f2e0f68d10caa7def61a996403a651; lines 53-68.
// Oracle: AcceptString("Hello") "Hello World"; AcceptName(n"Test") n"Test"; AcceptText FromString("Text") "Text".
// Extra: empty string concatenates " World"; empty FName stays NAME_None.
// DefaultSafe. Source owns locals.

FString AcceptString(FString x)
{
	return x + " World";
}

FName AcceptName(FName x)
{
	return x;
}

FString AcceptText(FText x)
{
	return x.ToString();
}

bool Observe_FunctionParametersValue_Nominal()
{
	return AcceptString("Hello") == "Hello World"
		&& AcceptName(n"Test") == n"Test"
		&& AcceptText(FText::FromString("Text")) == "Text";
}

bool Observe_AcceptString_EmptyDefault()
{
	return AcceptString("") == " World";
}

bool Observe_AcceptName_NoneBoundary()
{
	FName Empty;
	return AcceptName(Empty) == Empty;
}
