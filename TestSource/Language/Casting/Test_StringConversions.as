// Theme: Language.Casting. Positive FString/FName/FText and numeric formatting conversions.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::StringConversions
// Oracle: StringToName Convert; NameToString MyName; TextToString TextValue;
// StringToTextToString FromString; IntToString 123; FloatToString 2.5.
// Extra: empty FString -> None FName; FromInt(0) is "0".
// DefaultSafe. Source owns locals.

FName StringToName()
{
	FString s = "Convert";
	return FName(s);
}

FString NameToString()
{
	FName n = n"MyName";
	return n.ToString();
}

FString TextToString()
{
	FText t = FText::FromString("TextValue");
	return t.ToString();
}

FString StringToTextToString()
{
	FString s = "FromString";
	FText t = FText::FromString(s);
	return t.ToString();
}

FString IntToString()
{
	int x = 123;
	return FString::FromInt(x);
}

FString FloatToString()
{
	return FString::SanitizeFloat(2.5);
}

bool Observe_StringConversions_Nominal()
{
	return StringToName() == n"Convert"
		&& NameToString() == "MyName"
		&& TextToString() == "TextValue"
		&& StringToTextToString() == "FromString"
		&& IntToString() == "123"
		&& FloatToString() == "2.5";
}

bool Observe_StringToName_EmptyDefault()
{
	FString Empty;
	FName NoneName = FName(Empty);
	return NoneName.IsNone();
}

FString Observe_IntToString_ZeroBoundary()
{
	return FString::FromInt(0);
}
