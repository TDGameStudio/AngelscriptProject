/**
 * @version v1
 * @summary Observe exact FQuat component equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe exact FQuat component equality.
 * @topic Baseline
 */
// Yaw 90 is false versus Identity.
// Boundary/ownership: == is exact component equality, unlike Equals with
// tolerance. The operands are not mutated.

namespace TS_FQuat_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FQuat Left = FQuat::Identity;
		FQuat Right = FQuat::Identity;
		FQuat Doubled(0.0, 0.0, 0.0, 2.0);
		FQuat Yaw(FRotator(0, 90, 0));
		return Left == Right && !(Left == Doubled) && !(Left == Yaw);
	}
}
/** @end */
