// Purpose: Observe default and exact GUID formatting plus Parse/ParseExact
// success and failure.
// AS-facing API: FString Guid.ToString() const;
// FString Guid.ToString(EGuidFormats Format) const;
// bool FGuid::Parse(const FString& GuidString, FGuid& OutGuid);
// bool FGuid::ParseExact(const FString& GuidString, EGuidFormats Format, FGuid& OutGuid);
// Inputs: Guid(1,2,3,4), Digits and DigitsWithHyphens formats, empty string,
// and a Digits string parsed with the wrong exact format.
// Expected observations: Default ToString is non-empty. Parse of that text
// succeeds. Parse of empty text fails. ParseExact with the matching format
// succeeds and the mismatched format fails.
// Boundary/ownership: OutGuid is written only when the parse returns true.

namespace TS_FGuid_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FGuid Guid(1, 2, 3, 4);
		FString DefaultText = Guid.ToString();
		FString Digits = Guid.ToString(EGuidFormats::Digits);
		FString Hyphens = Guid.ToString(EGuidFormats::DigitsWithHyphens);
		FString ZeroText = FGuid(0, 0, 0, 0).ToString();
		return DefaultText.Len() > 0 && Digits.Len() > 0 && Hyphens.Len() > Digits.Len() && ZeroText.Len() > 0;
	}

	bool Observe_Parse_Nominal()
	{
		FGuid Guid(1, 2, 3, 4);
		FString Text = Guid.ToString();
		FGuid Parsed;
		bool bParsed = FGuid::Parse(Text, Parsed);
		FGuid Failed;
		bool bEmptyFailed = FGuid::Parse("", Failed);
		return bParsed && Parsed == Guid && !bEmptyFailed;
	}

	bool Observe_ParseExact_Nominal()
	{
		FGuid Guid(1, 2, 3, 4);
		FString Digits = Guid.ToString(EGuidFormats::Digits);
		FGuid Parsed;
		bool bExactDigits = FGuid::ParseExact(Digits, EGuidFormats::Digits, Parsed);
		FGuid Mismatched;
		bool bWrongFormat = FGuid::ParseExact(Digits, EGuidFormats::DigitsWithHyphens, Mismatched);
		return bExactDigits && Parsed == Guid && !bWrongFormat;
	}
}
