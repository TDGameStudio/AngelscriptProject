// Purpose: Observe squared distance, ExpandBy, and TransformBy on
// FBoxSphereBounds. The bool return is the runner-readable oracle.
// AS-facing API: ComputeSquaredDistanceFromBoxToPoint; ExpandBy; TransformBy.
// Inputs: Origin 0 extent 1 radius 2, interior point 0, exterior (5,0,0),
// ExpandAmount 1, identity transform.
// Expected observations: Interior distance is 0. Exterior distance is
// positive. ExpandBy increases radius. Identity transform preserves origin.
// Boundary/ownership: Helpers return new bounds or a scalar; the receiver is
// unchanged.

namespace TS_FBoxSphereBounds_Behavior_02
{
	bool Observe_ComputeSquaredDistanceFromBoxToPoint_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		float64 Interior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector::ZeroVector);
		float64 Exterior = Bounds.ComputeSquaredDistanceFromBoxToPoint(FVector(5, 0, 0));
		return Interior == 0.0 && Exterior > 0.0;
	}

	bool Observe_ExpandBy_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		FBoxSphereBounds Expanded = Bounds.ExpandBy(1.0);
		FBoxSphereBounds Zero = Bounds.ExpandBy(0.0);
		return Expanded.SphereRadius > Bounds.SphereRadius && Zero.SphereRadius == 2.0;
	}

	bool Observe_TransformBy_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 2.0);
		FBoxSphereBounds Transformed = Bounds.TransformBy(FTransform::Identity);
		return Transformed.Origin.X == 0.0 && Transformed.SphereRadius == 2.0;
	}
}
