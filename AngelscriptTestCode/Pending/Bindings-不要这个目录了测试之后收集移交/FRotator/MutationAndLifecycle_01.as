/**
 * @version v1
 * @summary Observe FString.Append of an FRotator, including repeated append and Empty restoration.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FString.Append of an FRotator, including repeated append and Empty restoration.
 * @topic Baseline
 */
// Empty restores length 0. The rotator is unchanged.
// Boundary/ownership: Append copies formatted rotator text into the string.
// The FRotator value is not mutated.

namespace TS_FRotator_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "rot:";
		FRotator Rotator(10.0, 20.0, 30.0);
		int Before = Text.Len();
		Text.Append(Rotator);
		int AfterFirst = Text.Len();
		Text.Append(Rotator);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Rotator.Pitch == 10.0;
	}
}
/** @end */
