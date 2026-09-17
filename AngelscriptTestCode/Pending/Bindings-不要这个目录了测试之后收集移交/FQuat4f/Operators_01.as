/**
 * @version v1
 * @summary Observe exact FQuat4f component equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe exact FQuat4f component equality.
 * @topic Baseline
 */
// Yaw 90 is false versus Identity.
// Boundary/ownership: == is exact component equality, unlike Equals with
// tolerance. The operands are not mutated.

namespace TS_FQuat4f_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FQuat4f Left = FQuat4f::Identity;
		FQuat4f Right = FQuat4f::Identity;
		FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		return Left == Right && !(Left == Doubled) && !(Left == Yaw);
	}
}
/** @end */
