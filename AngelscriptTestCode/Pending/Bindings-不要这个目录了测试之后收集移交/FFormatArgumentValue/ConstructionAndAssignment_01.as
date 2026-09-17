/**
 * @version v1
 * @summary Observe FFormatArgumentValue as a tagged localized-format argument value type, including copy assignment independence.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FFormatArgumentValue as a tagged localized-format argument value type, including copy assignment independence.
 * @topic Baseline
 */
// assignment of a different int32 9.
// Expected observations: Copies can be assigned. Default and numeric
// constructions both produce usable format arguments that FText::Format can
// consume later.
// Boundary/ownership: The tagged value copies the numeric or FText payload.
// It does not retain a script object handle.

namespace TS_FFormatArgumentValue_ConstructionAndAssignment_01
{
	// FFormatArgumentValue default, int32(7), copy, then assign int32(9).
	// Oracle: FText::Format("{0}", Numeric) is "7". Value type, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FFormatArgumentValue DefaultValue;
		FFormatArgumentValue Numeric(7);
		FFormatArgumentValue Copied = Numeric;
		Copied = FFormatArgumentValue(9);
		FText Pattern = FText::FromString("{0}");
		FText Formatted = FText::Format(Pattern, Numeric);
		FString Text = Formatted.ToString();
		FString CopiedText = FText::Format(Pattern, Copied).ToString();
		return Text == "7" && CopiedText == "9";
	}
}
/** @end */
