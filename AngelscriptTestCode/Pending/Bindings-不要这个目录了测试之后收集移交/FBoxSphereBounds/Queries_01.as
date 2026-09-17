/**
 * @version v1
 * @summary Observe box/sphere extraction and extrema corners.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe box/sphere extraction and extrema corners.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FBox Bounds.GetBox() const;
// FVector Bounds.GetBoxExtrema(uint32 Extrema) const;
// FSphere Bounds.GetSphere() const;
// Inputs: Origin 0, extent (1,1,1), radius 2, extrema 0 and 1.
// Expected observations: GetBox min/max match origin +/- extent. Extrema 0
// is the minimum corner. GetSphere radius is 2.
// Boundary/ownership: GetBox/GetSphere return value copies.

namespace TS_FBoxSphereBounds_Queries_01
{
	bool Observe_GetBox_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		FBox Box = Bounds.GetBox();
		return Box.Min.X == -1.0 && Box.Max.X == 1.0;
	}

	bool Observe_GetBoxExtrema_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		FVector MinCorner = Bounds.GetBoxExtrema(0);
		FVector MaxCorner = Bounds.GetBoxExtrema(1);
		return MinCorner.X == -1.0 && MaxCorner.X == 1.0;
	}

	bool Observe_GetSphere_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		FSphere Sphere = Bounds.GetSphere();
		return Sphere.W == 2.0;
	}
}
/** @end */
