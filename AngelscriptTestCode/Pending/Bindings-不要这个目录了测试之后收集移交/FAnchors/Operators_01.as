/**
 * @version v1
 * @summary Observe FAnchors equality of every normalized coordinate.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAnchors equality of every normalized coordinate.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Identical (0.5, 0.5) point anchors, a stretched (0,0,1,1) range,
// and a zero uniform 0.0 anchor.
// Expected observations: Identical constructors compare true. Point vs
// stretched range is false. Equality does not mutate either operand.
// Boundary/ownership: Comparison is by all four min/max coordinates.

namespace TS_FAnchors_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FAnchors Left(0.5, 0.5);
		FAnchors Right(0.5, 0.5);
		FAnchors Stretched(0.0, 0.0, 1.0, 1.0);
		FAnchors Zero(0.0);
		return Left == Right && !(Left == Stretched) && !(Left == Zero);
	}
}
/** @end */
