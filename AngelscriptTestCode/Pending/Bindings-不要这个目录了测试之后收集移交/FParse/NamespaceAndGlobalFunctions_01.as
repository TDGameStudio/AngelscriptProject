/**
 * @version v1
 * @summary Observe FParse::Value and FParse::Bool writing parsed results and returning false for missing matches.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FParse::Value and FParse::Bool writing parsed results and returning false for missing matches.
 * @topic Baseline
 */
// FString& Value);
// bool FParse::Value(const FString& Stream, const FString& Match, float32& Value);
// bool FParse::Value(const FString& Stream, const FString& Match, int& Value);
// bool FParse::Bool(const FString& Stream, const FString& Match, bool& OnOff);
// Inputs: Stream "Count=12 Ratio=3.5 Name=Alpha Enabled=true", match prefixes
// with '=', missing match "Missing=", empty stream, and default out values.
// Expected observations: Successful parses return true and write 12, 3.5,
// "Alpha", and true. Missing matches return false. Out values are recorded
// before and after each call.
// Boundary/ownership: Out parameters are written in place. Stream and Match
// are borrowed.

namespace TS_FParse_NamespaceAndGlobalFunctions_01
{
	bool Observe_Value_Nominal()
	{
		FString Stream = "Count=12 Ratio=3.5 Name=Alpha Enabled=true";

		FString Name;
		bool bNameBeforeEmpty = Name.IsEmpty();
		bool bNameParsed = FParse::Value(Stream, "Name=", Name);
		bool bNameWriteback = Name == "Alpha";

		float32 Ratio = 0.0;
		bool bRatioParsed = FParse::Value(Stream, "Ratio=", Ratio);
		bool bRatioWriteback = Ratio == 3.5;

		int Count = 0;
		bool bCountParsed = FParse::Value(Stream, "Count=", Count);
		bool bCountWriteback = Count == 12;

		FString Missing;
		bool bMissingParsed = FParse::Value(Stream, "Missing=", Missing);
		bool bMissingUnchanged = Missing.IsEmpty();

		FString EmptyStream;
		FString EmptyValue;
		bool bEmptyParsed = FParse::Value(EmptyStream, "Name=", EmptyValue);

		return bNameBeforeEmpty && bNameParsed && bNameWriteback && bRatioParsed && bRatioWriteback && bCountParsed && bCountWriteback && !bMissingParsed && bMissingUnchanged && !bEmptyParsed;
	}

	bool Observe_Bool_Nominal()
	{
		FString Stream = "Count=12 Ratio=3.5 Name=Alpha Enabled=true";
		bool bEnabled = false;
		bool bParsed = FParse::Bool(Stream, "Enabled=", bEnabled);
		bool bOnOffWriteback = bEnabled;

		bool bMissingFlag = true;
		bool bMissingParsed = FParse::Bool(Stream, "Missing=", bMissingFlag);
		FString EmptyStream;
		bool bEmptyFlag = false;
		bool bEmptyParsed = FParse::Bool(EmptyStream, "Enabled=", bEmptyFlag);

		return bParsed && bOnOffWriteback && !bMissingParsed && !bEmptyParsed && !bEmptyFlag;
	}
}
/** @end */
