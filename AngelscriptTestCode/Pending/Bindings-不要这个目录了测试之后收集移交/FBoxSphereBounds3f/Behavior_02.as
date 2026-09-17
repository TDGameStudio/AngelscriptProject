/**
 * @version v1
 * @summary Observe squared distance, ExpandBy, and TransformBy on FBoxSphereBounds3f. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe squared distance, ExpandBy, and TransformBy on FBoxSphereBounds3f. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// identity transform.
// Expected observations: Interior distance 0. Exterior distance positive.
// ExpandBy increases radius. Identity preserves origin.
// Boundary/ownership: Helpers return new values; the receiver is unchanged.

namespace TS_FBoxSphereBounds3f_Behavior_02
{
	bool Observe_ComputeSquaredDistanceFromBoxToPoint_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		float32 Interior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector3f::ZeroVector);
		float32 Exterior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector3f(5, 0, 0));
		return Interior == 0.0 && Exterior > 0.0;
	}

	bool Observe_ExpandBy_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		FBoxSphereBounds3f Expanded = Bounds.ExpandBy(1.0);
		return Expanded.SphereRadius > Bounds.SphereRadius;
	}

	bool Observe_TransformBy_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 2.0);
		FBoxSphereBounds3f Transformed = Bounds.TransformBy(FTransform3f::Identity);
		return Transformed.Origin.X == 0.0 && Transformed.SphereRadius == 2.0;
	}
}
/** @end */
