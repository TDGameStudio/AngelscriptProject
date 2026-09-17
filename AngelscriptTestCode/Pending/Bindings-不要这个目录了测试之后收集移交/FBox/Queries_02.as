/**
 * @version v1
 * @summary Observe XY-plane inside tests for points-on-edge and contained boxes. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe XY-plane inside tests for points-on-edge and contained boxes. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// bool Box.IsInsideXY(const FBox& In) const;
// Inputs: Box (0,0,0)-(2,2,2), on-edge XY point (0,1,9), exterior XY (3,1,1),
// inner XY box, and a box that extends outside in XY.
// Expected observations: On-edge XY is inside-or-on. Exterior XY is false.
// Inner XY box is inside; overflowing XY box is not.
// Boundary/ownership: Z is ignored for XY tests. Queries do not mutate Box.

namespace TS_FBox_Queries_02
{
	bool Observe_IsInsideOrOnXY_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		return Box.IsInsideOrOnXY(FVector(0, 1, 9)) && !Box.IsInsideOrOnXY(FVector(3, 1, 1));
	}

	bool Observe_IsInsideXY_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Inner(FVector(0.5, 0.5, 9), FVector(1.5, 1.5, 10));
		FBox Overflow(FVector(-1, 0.5, 0), FVector(1, 1, 1));
		return Box.IsInsideXY(Inner) && !Box.IsInsideXY(Overflow);
	}
}
/** @end */
