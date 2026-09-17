/**
 * @version v1
 * @summary Observe FString.Append of an FBox3f, including repeated append and Empty restoration. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FString.Append of an FBox3f, including repeated append and Empty restoration. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// Empty restores length 0. The box is unchanged.
// Boundary/ownership: Append copies formatted text. The box is not mutated.

namespace TS_FBox3f_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "box:";
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		int Before = Text.Len();
		Text.Append(Box);
		int AfterFirst = Text.Len();
		Text.Append(Box);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Box.Max.X == 1.0;
	}
}
/** @end */
