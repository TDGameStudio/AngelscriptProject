// Purpose: Observe FBoxSphereBounds constructors and Origin/BoxExtent/
// SphereRadius fields. The bool return is the runner-readable oracle.
// AS-facing API: Bounds(); Bounds(Origin, Extent, Radius); Bounds(Box, Sphere);
// Bounds(FBoxSphereBounds3f); Bounds(Box); Bounds(Sphere); Bounds(Points);
// Origin; BoxExtent; SphereRadius.
// Inputs: Zero defaults, origin/extent/radius 1, a unit box and sphere,
// a single-precision bounds, and a two-point array.
// Expected observations: Origin/extent/radius constructors store those
// fields. Box constructor radius is positive. Points constructor includes
// both points.
// Boundary/ownership: Default construction is a zero/empty bounds.

namespace TS_FBoxSphereBounds_Behavior_01
{
	// FBoxSphereBounds from parts, box, sphere, FBoxSphereBounds3f, and points. Oracle: Origin.X==1, radius 2, FromBox radius>0, points extent>0. Value type.
	bool Observe_Bounds_Nominal()
	{
		FBoxSphereBounds DefaultBounds;
		FBoxSphereBounds FromParts(FVector(1, 1, 1), FVector(1, 1, 1), 2.0);
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FSphere Sphere(FVector(1, 1, 1), 2.0);
		FBoxSphereBounds FromBoxSphere(Box, Sphere);
		FBoxSphereBounds3f Single(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds FromSingle(Single);
		FBoxSphereBounds FromBox(Box);
		FBoxSphereBounds FromSphere(Sphere);
		TArray<FVector> Points;
		Points.Add(FVector::ZeroVector);
		Points.Add(FVector(2, 2, 2));
		FBoxSphereBounds FromPoints(Points);
		return FromParts.Origin.X == 1.0 && FromParts.SphereRadius == 2.0 && FromBox.SphereRadius > 0.0 && FromPoints.BoxExtent.X > 0.0 && FromSingle.SphereRadius > 0.0 && FromBoxSphere.SphereRadius > 0.0 && FromSphere.SphereRadius > 0.0 && DefaultBounds.SphereRadius == 0.0;
	}

	// FBoxSphereBounds.Origin on (1,0,0) extent 1 radius 2. Oracle: Origin.X==1. Field read does not mutate.
	bool Observe_Surface008_Nominal()
	{
		FBoxSphereBounds Bounds(FVector(1, 0, 0), FVector(1, 1, 1), 2.0);
		return Bounds.Origin.X == 1.0;
	}

	// FBoxSphereBounds.BoxExtent on origin 0 extent (2,1,1). Oracle: BoxExtent.X==2. Field read does not mutate.
	bool Observe_Surface009_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(2, 1, 1), 2.0);
		return Bounds.BoxExtent.X == 2.0;
	}

	// FBoxSphereBounds.SphereRadius on origin 0 radius 3. Oracle: SphereRadius==3. Field read does not mutate.
	bool Observe_Surface010_Nominal()
	{
		FBoxSphereBounds Bounds(FVector::ZeroVector, FVector(1, 1, 1), 3.0);
		return Bounds.SphereRadius == 3.0;
	}
}
