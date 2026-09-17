/**
 * @version v1
 * @summary Observe uniform, point, and ranged FAnchors constructors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe uniform, point, and ranged FAnchors constructors.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FAnchors Anchors(float32 UnifromAnchors);
// FAnchors Anchors(float32 Horizontal, float32 Vertical);
// FAnchors Anchors(float32 MinX, float32 MinY, float32 MaxX, float32 MaxY);
// Inputs: Uniform 0.5, point (0.25, 0.75), range (0,0,1,1), and uniform 0.0
// as the empty coordinate.
// Expected observations: Uniform 0.5 is not stretched. Range (0,0,1,1) is
// stretched on both axes. Point constructor equals a range with min==max.
// Boundary/ownership: UniformAnchors is shared on both axes. Values are
// normalized widget coordinates, not pixels.

namespace TS_FAnchors_Behavior_01
{
	bool Observe_Anchors_Nominal()
	{
		FAnchors Uniform(0.5);
		FAnchors Point(0.25, 0.75);
		FAnchors Range(0.0, 0.0, 1.0, 1.0);
		FAnchors Zero(0.0);
		FAnchors PointAsRange(0.25, 0.75, 0.25, 0.75);
		return !Uniform.IsStretchedHorizontal() && !Uniform.IsStretchedVertical() && Range.IsStretchedHorizontal() && Range.IsStretchedVertical() && Point == PointAsRange && !Zero.IsStretchedHorizontal();
	}
}
/** @end */
