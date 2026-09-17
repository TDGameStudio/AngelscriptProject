/**
 * @version v1
 * @summary Observe single-precision box/sphere extraction and extrema.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe single-precision box/sphere extraction and extrema.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: GetBox; GetBoxExtrema; GetSphere.
// Inputs: Origin 0, extent 1, radius 2, extrema 0 and 1.
// Expected observations: GetBox min is -1. Extrema 0/1 are min/max corners.
// Sphere radius is 2.
// Boundary/ownership: Returned FBox3f/FSphere3f are value copies.

namespace TS_FBoxSphereBounds3f_Queries_01
{
	bool Observe_GetBox_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		FBox3f Box = Bounds.GetBox();
		return Box.Min.X == -1.0 && Box.Max.X == 1.0;
	}

	bool Observe_GetBoxExtrema_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		FVector3f MinCorner = Bounds.GetBoxExtrema(0);
		FVector3f MaxCorner = Bounds.GetBoxExtrema(1);
		return MinCorner.X == -1.0 && MaxCorner.X == 1.0;
	}

	bool Observe_GetSphere_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		FSphere3f Sphere = Bounds.GetSphere();
		return Sphere.W == 2.0;
	}
}
/** @end */
