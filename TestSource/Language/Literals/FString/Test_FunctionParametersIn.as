// Theme: Language.Literals.FString. Positive FString/FName/FText &in parameters.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersIn
// sha256=06ac536d14a9069319bd97588bc0cf704bd7c77c43d65fc48b873ceb181f2332; lines 131-146.
// Oracle: AcceptStringIn("Test") "Received: Test"; AcceptNameIn n"MyName"; AcceptTextIn "InputText".
// Extra: empty &in string; empty FText ToString.
// DefaultSafe. Source owns locals.

FString AcceptStringIn(FString&in x)
{
	return "Received: " + x;
}

FName AcceptNameIn(FName&in x)
{
	return x;
}

FString AcceptTextIn(FText&in x)
{
	return x.ToString();
}

bool Observe_FunctionParametersIn_Nominal()
{
	FString InputString = "Test";
	FName InputName = n"MyName";
	FText InputText = FText::FromString("InputText");
	return AcceptStringIn(InputString) == "Received: Test"
		&& AcceptNameIn(InputName) == n"MyName"
		&& AcceptTextIn(InputText) == "InputText";
}

bool Observe_AcceptStringIn_EmptyDefault()
{
	FString Empty = "";
	return AcceptStringIn(Empty) == "Received: ";
}

bool Observe_AcceptTextIn_EmptyBoundary()
{
	FText Empty;
	return AcceptTextIn(Empty) == "";
}
