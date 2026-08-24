// Theme: Language.Literals.FString. Positive FString/FName/FText return values.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionReturnValues
// sha256 from TS-LANG-0145; lines 385-404.
// Oracle: ReturnString "Hello World"; ReturnName n"MyName"; ReturnEmpty ""; ReturnText "ReturnText".
// Extra: empty return is Len 0; FName return is not NAME_None.
// DefaultSafe. Source owns locals.

FString ReturnString()
{
	return "Hello World";
}

FName ReturnName()
{
	return n"MyName";
}

FString ReturnEmpty()
{
	return "";
}

FText ReturnText()
{
	return FText::FromString("ReturnText");
}

bool Observe_FunctionReturnValues_Nominal()
{
	return ReturnString() == "Hello World"
		&& ReturnName() == n"MyName"
		&& ReturnText().ToString() == "ReturnText";
}

bool Observe_ReturnEmpty_Default()
{
	return ReturnEmpty() == "" && ReturnEmpty().Len() == 0;
}

bool Observe_ReturnName_NotNoneBoundary()
{
	FName Empty;
	return ReturnName() != Empty;
}
