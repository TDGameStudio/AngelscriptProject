// Purpose: Observe FBoxSphereBounds3f constructors and Origin/BoxExtent/
// SphereRadius fields. The bool return is the runner-readable oracle.
// AS-facing API: Bounds(); Bounds(Origin, Extent, Radius); Bounds(FBoxSphereBounds);
// Bounds(Box, Sphere); Bounds(Box); Bounds(Sphere); Bounds(Points);
// Origin; BoxExtent; SphereRadius.
// Inputs: Default, parts (1,1,1)/1/2, double-precision conversion, a unit
// FBox3f, two FVector3f points.
// Expected observations: Parts constructor stores origin 1 and radius 2.
// Conversion from 64-bit bounds is finite. Points constructor has positive
// extent.
// Boundary/ownership: Default is an empty/zero bounds.

namespace TS_FBoxSphereBounds3f_Behavior_01
{
	// FBoxSphereBounds3f from parts, FBoxSphereBounds, box, sphere, and points. Oracle: Origin.X==1, radius 2, converted radius>0, points extent>0. Value type.
	bool Observe_Bounds_Nominal()
	{
		FBoxSphereBounds3f DefaultBounds;
		FBoxSphereBounds3f FromParts(FVector3f(1, 1, 1), FVector3f(1, 1, 1), 2.0);
		FBoxSphereBounds DoubleBounds(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds3f FromDouble(DoubleBounds);
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FSphere3f Sphere(FVector3f(1, 1, 1), 2.0);
		FBoxSphereBounds3f FromBoxSphere(Box, Sphere);
		FBoxSphereBounds3f FromBox(Box);
		FBoxSphereBounds3f FromSphere(Sphere);
		TArray<FVector3f> Points;
		Points.Add(FVector3f::ZeroVector);
		Points.Add(FVector3f(2, 2, 2));
		FBoxSphereBounds3f FromPoints(Points);
		return FromParts.Origin.X == 1.0 && FromParts.SphereRadius == 2.0 && FromDouble.SphereRadius > 0.0 && FromPoints.BoxExtent.X > 0.0 && FromBoxSphere.SphereRadius > 0.0 && FromBox.SphereRadius > 0.0 && FromSphere.SphereRadius > 0.0 && DefaultBounds.SphereRadius == 0.0;
	}

	// FBoxSphereBounds3f.Origin on (1,0,0) extent 1 radius 2. Oracle: Origin.X==1. Field read does not mutate.
	bool Observe_Surface008_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 2.0);
		return Bounds.Origin.X == 1.0;
	}

	// FBoxSphereBounds3f.BoxExtent on origin 0 extent (2,1,1). Oracle: BoxExtent.X==2. Field read does not mutate.
	bool Observe_Surface009_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(2, 1, 1), 2.0);
		return Bounds.BoxExtent.X == 2.0;
	}

	// FBoxSphereBounds3f.SphereRadius on origin 0 radius 3. Oracle: SphereRadius==3. Field read does not mutate.
	bool Observe_Surface010_Nominal()
	{
		FBoxSphereBounds3f Bounds(FVector3f::ZeroVector, FVector3f(1, 1, 1), 3.0);
		return Bounds.SphereRadius == 3.0;
	}
}
