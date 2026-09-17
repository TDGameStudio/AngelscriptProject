/**
 * @version v1
 * @summary Observe IsValidIndex for empty strings, first/last positions, and the invalid index diagnostic companion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe IsValidIndex for empty strings, first/last positions, and the invalid index diagnostic companion.
 * @topic Baseline
 */
// on "ab". -1 and Len() are false.
// Boundary/ownership: Index addresses a UTF-16 code unit, not a glyph. The
// query does not mutate the string.

namespace TS_FString_IndexAndIteration_01
{
	bool Observe_IsValidIndex_Nominal()
	{
		FString Empty;
		FString Text = "ab";
		return !Empty.IsValidIndex(0) && Text.IsValidIndex(0) && Text.IsValidIndex(1) && !Text.IsValidIndex(2) && !Text.IsValidIndex(-1);
	}

	void ExerciseExpectedFailure()
	{
		FString Text = "a";
		int16 OutOfRange = Text[Text.Len()];
	}
}
/** @end */
