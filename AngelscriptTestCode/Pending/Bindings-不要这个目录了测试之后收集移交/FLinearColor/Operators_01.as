/**
 * @version v1
 * @summary Observe exact FLinearColor equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe exact FLinearColor equality.
 * @topic Baseline
 */
// false. Alpha difference is false.
// Boundary/ownership: Equality is exact channel comparison, unlike Equals
// with tolerance.

namespace TS_FLinearColor_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FLinearColor Left(0.2, 0.4, 0.6, 1.0);
		FLinearColor Right(0.2, 0.4, 0.6, 1.0);
		FLinearColor Alpha(0.2, 0.4, 0.6, 0.0);
		return (Left == Right) && !(Left == FLinearColor::Black) && !(Left == Alpha);
	}
}
/** @end */
