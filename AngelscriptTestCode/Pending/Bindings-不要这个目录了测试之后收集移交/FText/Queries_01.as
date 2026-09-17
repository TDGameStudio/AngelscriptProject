/**
 * @version v1
 * @summary Observe FText emptiness, transience, culture invariance, string origin, string-table origin, and format-pattern parameter extraction.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FText emptiness, transience, culture invariance, string origin, string-table origin, and format-pattern parameter extraction.
 * @topic Baseline
 */
// IsTransient; IsCultureInvariant; IsInitializedFromString; IsFromStringTable;
// void FText::GetFormatPatternParameters(const FText& Fmt, TArray<FString>&out ParameterNames);
// Inputs: Empty FText, FromString("Hello"), AsCultureInvariant("x"),
// whitespace "  ", and pattern "{Name}" as Fmt.
// Expected observations: Empty is empty. FromString is initialized from
// string and not from a string table. Culture-invariant reports true.
// GetFormatPatternParameters writes "Name".
// Boundary/ownership: Out ParameterNames is a writeback array. Queries do
// not mutate the FText.

namespace TS_FText_Queries_01
{
	bool Observe_IsEmpty_Nominal()
	{
		FText Empty;
		FText Hello = FText::FromString("Hello");
		return Empty.IsEmpty() && !Hello.IsEmpty();
	}

	bool Observe_IsEmptyOrWhitespace_Nominal()
	{
		FText Empty;
		FText Whitespace = FText::FromString("  ");
		FText Hello = FText::FromString("Hello");
		return Empty.IsEmptyOrWhitespace() && Whitespace.IsEmptyOrWhitespace() && !Hello.IsEmptyOrWhitespace();
	}

	bool Observe_IsTransient_Nominal()
	{
		FText FromString = FText::FromString("Hello");
		return !FromString.IsTransient();
	}

	bool Observe_IsCultureInvariant_Nominal()
	{
		FText Invariant = FText::AsCultureInvariant("x");
		FText Localized = NSLOCTEXT("TestSource", "Greeting", "Hello");
		return Invariant.IsCultureInvariant() && !Localized.IsCultureInvariant();
	}

	bool Observe_IsInitializedFromString_Nominal()
	{
		FText FromString = FText::FromString("Hello");
		FText Empty;
		return FromString.IsInitializedFromString() && !Empty.IsInitializedFromString();
	}

	bool Observe_IsFromStringTable_Nominal()
	{
		FText FromString = FText::FromString("Hello");
		return !FromString.IsFromStringTable();
	}

	bool Observe_GetFormatPatternParameters_Nominal()
	{
		FText Pattern = FText::FromString("{Name}");
		TArray<FString> ParameterNames;
		FText::GetFormatPatternParameters(Pattern, ParameterNames);
		TArray<FString> EmptyNames;
		FText::GetFormatPatternParameters(FText::FromString("plain"), EmptyNames);
		return ParameterNames.Num() > 0 && ParameterNames[0] == "Name" && EmptyNames.Num() == 0;
	}
}
/** @end */
