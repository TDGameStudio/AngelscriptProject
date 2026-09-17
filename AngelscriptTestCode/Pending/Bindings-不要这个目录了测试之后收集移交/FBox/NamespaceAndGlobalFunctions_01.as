/**
 * @version v1
 * @summary Observe FBox::BuildAABB from origin and extent.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox::BuildAABB from origin and extent.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBox FBox::BuildAABB(const FVector& Origin, const FVector& Extent);
// Inputs: Origin (1,1,1), Extent (1,1,1), and ZeroVector extent as the empty
// volume case.
// Expected observations: Result min is (0,0,0) and max is (2,2,2). Zero
// extent yields min==max at the origin.
// Boundary/ownership: BuildAABB returns a new box. Origin is the center, not
// a corner.

namespace TS_FBox_NamespaceAndGlobalFunctions_01
{
	bool Observe_BuildAABB_Nominal()
	{
		FBox Box = FBox::BuildAABB(FVector(1, 1, 1), FVector(1, 1, 1));
		FBox Degenerate = FBox::BuildAABB(FVector(1, 1, 1), FVector::ZeroVector);
		return Box.Min.X == 0.0 && Box.Max.X == 2.0 && Degenerate.Min.X == 1.0 && Degenerate.Max.X == 1.0;
	}
}
/** @end */
