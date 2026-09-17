/**
 * @version v1
 * @summary Observe FBox3f::BuildAABB from origin and extent.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox3f::BuildAABB from origin and extent.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBox3f FBox3f::BuildAABB(const FVector3f& Origin, const FVector3f& Extent);
// Inputs: Origin (1,1,1), Extent (1,1,1), zero extent.
// Expected observations: Min is (0,0,0) and Max is (2,2,2). Zero extent is
// a point box at the origin.
// Boundary/ownership: Origin is the center. The factory returns a new box.

namespace TS_FBox3f_NamespaceAndGlobalFunctions_01
{
	bool Observe_BuildAABB_Nominal()
	{
		FBox3f Box = FBox3f::BuildAABB(FVector3f(1, 1, 1), FVector3f(1, 1, 1));
		FBox3f Degenerate = FBox3f::BuildAABB(FVector3f(1, 1, 1), FVector3f(0, 0, 0));
		return Box.Min.X == 0.0 && Box.Max.X == 2.0 && Degenerate.Min.X == 1.0 && Degenerate.Max.X == 1.0;
	}
}
/** @end */
