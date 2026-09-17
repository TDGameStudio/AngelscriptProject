/**
 * @version v1
 * @summary Observe FString.Append of an FVector2D, including repeated append and Empty restoration.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FString.Append of an FVector2D, including repeated append and Empty restoration.
 * @topic Baseline
 */
// Empty restores length 0. The vector is unchanged.
// Boundary/ownership: Append copies formatted text. The vector is not mutated.

namespace TS_FVector2D_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "v:";
		FVector2D Vector(1, 2);
		int Before = Text.Len();
		Text.Append(Vector);
		int AfterFirst = Text.Len();
		Text.Append(Vector);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.X == 1.0;
	}
}
/** @end */
