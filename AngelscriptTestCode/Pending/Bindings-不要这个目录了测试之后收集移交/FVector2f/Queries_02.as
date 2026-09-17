/**
 * @version v1
 * @summary Observe FVector2f.GetClampedToMaxSize for long, short, and zero vectors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f.GetClampedToMaxSize for long, short, and zero vectors.
 * @topic Baseline
 */
// Zero stays zero.
// Boundary/ownership: Returns a copy. Max is a length, not a per-component
// clamp. Max is float32.

namespace TS_FVector2f_Queries_02
{
	bool Observe_GetClampedToMaxSize_Nominal()
	{
		FVector2f Long = FVector2f(10.0f, 0.0f).GetClampedToMaxSize(5.0f);
		FVector2f Short = FVector2f(1.0f, 0.0f).GetClampedToMaxSize(5.0f);
		FVector2f Zero = FVector2f(0.0f, 0.0f).GetClampedToMaxSize(5.0f);
		return Long.Equals(FVector2f(5.0f, 0.0f)) && Short.Equals(FVector2f(1.0f, 0.0f)) && Zero.IsZero();
	}
}
/** @end */
