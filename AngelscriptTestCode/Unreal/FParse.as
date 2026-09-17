/**
 * @version v1
 * @summary FParse host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FParse
 *
 * are-borrowed
 * bool
 */
/**
 * @begin are-borrowed
 * @summary are borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary are borrowed.
 * @covers FParse.are-borrowed
 * @inputs FParse values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveValueNominal()
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
/** @end */
/**
 * @begin bool
 * @summary are borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveBoolNominal
 * @summary are borrowed.
 * @covers FParse.bool
 * @inputs FParse values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveBoolNominal()
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
/** @end */
