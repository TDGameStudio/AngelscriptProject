/**
 * @version v1
 * @summary Observe exact FRotator3f equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe exact FRotator3f equality.
 * @topic Baseline
 */
// false. Zero equals ZeroRotator.
// Boundary/ownership: == compares raw degree components exactly.

namespace TS_FRotator3f_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FRotator3f Left(10.0, 20.0, 30.0);
		FRotator3f Right(10.0, 20.0, 30.0);
		FRotator3f Different(10.0, 21.0, 30.0);
		FRotator3f Zero;
		return (Left == Right) && !(Left == Different) && (Zero == FRotator3f::ZeroRotator);
	}
}
/** @end */
