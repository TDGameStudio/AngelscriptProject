/**
 * @version v1
 * @summary Observe TSet equality by element contents, independent of Add order.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSet equality by element contents, independent of Add order.
 * @topic Baseline
 */
// sets, and a different set {1}.
// Expected observations: Same elements compare true regardless of insertion
// order. Empty == empty is true. Populated vs empty is false. Different Num
// compares false.
// Boundary/ownership: Equality is value-returning and does not mutate either
// set. Storage order is not part of the comparison.

namespace TS_TSet_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		TSet<int32> Left;
		Left.Add(1);
		Left.Add(2);
		TSet<int32> Right;
		Right.Add(2);
		Right.Add(1);
		TSet<int32> EmptyLeft;
		TSet<int32> EmptyRight;
		TSet<int32> Different;
		Different.Add(1);
		return Left == Right && EmptyLeft == EmptyRight && !(Left == EmptyLeft) && !(Left == Different);
	}
}
/** @end */
