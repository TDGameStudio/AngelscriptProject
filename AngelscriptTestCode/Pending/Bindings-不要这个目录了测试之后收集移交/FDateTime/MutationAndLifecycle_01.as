/**
 * @version v1
 * @summary Observe FString.Append of an FDateTime, including repeated append and restoration via Empty.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FString.Append of an FDateTime, including repeated append and restoration via Empty.
 * @topic Baseline
 */
// value, and Empty() as cleanup.
// Expected observations: First append increases length. Second append grows
// further. Empty restores length 0.
// Boundary/ownership: Append copies formatted date-time text into the string.
// The FDateTime value is not mutated.

namespace TS_FDateTime_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "when:";
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		int Before = Text.Len();
		Text.Append(DateTime);
		int AfterFirst = Text.Len();
		Text.Append(DateTime);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.Len() == 0;
	}
}
/** @end */
