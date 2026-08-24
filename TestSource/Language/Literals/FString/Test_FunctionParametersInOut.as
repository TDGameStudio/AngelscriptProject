// Theme: Language.Literals.FString. Positive FString/FName/FText &inout parameters.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersInOut
// sha256=31860af3aecd615ea6c904a5be709bcf1c1e26de9278b816ebc7590de3c8dd62; lines 303-324.
// Oracle: AppendToString "Original Appended"; ReplaceName n"UpdatedName"; ReplaceText "UpdatedText".
// Extra: unmatched name/text leave values unchanged; empty append still adds suffix.
// DefaultSafe. Source owns locals.

void AppendToString(FString&inout x)
{
	x += " Appended";
}

void ReplaceName(FName&inout x)
{
	if (x == n"OriginalName")
	{
		x = n"UpdatedName";
	}
}

void ReplaceText(FText&inout x)
{
	if (x.ToString() == "OriginalText")
	{
		x = FText::FromString("UpdatedText");
	}
}

bool Observe_FunctionParametersInOut_Nominal()
{
	FString Value = "Original";
	AppendToString(Value);
	FName NameValue = n"OriginalName";
	ReplaceName(NameValue);
	FText TextValue = FText::FromString("OriginalText");
	ReplaceText(TextValue);
	return Value == "Original Appended"
		&& NameValue == n"UpdatedName"
		&& TextValue.ToString() == "UpdatedText";
}

bool Observe_AppendToString_EmptyDefault()
{
	FString Empty = "";
	AppendToString(Empty);
	return Empty == " Appended";
}

bool Observe_ReplaceName_UnchangedBoundary()
{
	FName Value = n"OtherName";
	ReplaceName(Value);
	return Value == n"OtherName";
}
