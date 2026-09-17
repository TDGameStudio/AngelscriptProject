/**
 * @version v1
 * @summary Observe FString.Append of an FVector4f, including repeated append and Empty restoration.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FString.Append of an FVector4f, including repeated append and Empty restoration.
 * @topic Baseline
 */
// Empty restores length 0. The vector is unchanged.
// Boundary/ownership: Append copies formatted text. The vector is not mutated.

namespace TS_FVector4f_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "v:";
		FVector4f Vector(1.0f, 2.0f, 3.0f, 4.0f);
		int Before = Text.Len();
		Text.Append(Vector);
		int AfterFirst = Text.Len();
		Text.Append(Vector);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.W == 4.0f;
	}
}
/** @end */
