/**
 * @version v1
 * @summary Observe FSphere3f constructors, W/Center fields, and intersection.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FSphere3f constructors, W/Center fields, and intersection.
 * @topic Baseline
 */
// Sphere(FSphere); Sphere(Points); W; Center; Intersects.
// Inputs: Default zero sphere, center (1,2,3) radius 4, copy, FSphere
// conversion, two-point array, overlapping and disjoint neighbors.
// Expected observations: Center/radius ctor stores Center and W. Default W is
// 0. Copy and FSphere convert. Points sphere radius is positive. Overlapping
// Intersects is true; disjoint is false.
// Boundary/ownership: Radius is W. Intersects does not mutate either sphere.

namespace TS_FSphere3f_Behavior_01
{
	// FSphere3f constructors: default, center/radius, copy, FSphere, and
	// points. Inputs (1,2,3)/4, FSphere radius 2, and two points on X.
	// Default W is 0; copy stays 4 after mutating the source; points W > 0.
	// Copy is independent of later source mutation.
	bool Observe_Sphere_Nominal()
	{
		FSphere3f DefaultSphere;
		FSphere3f FromCenter(FVector3f(1.0, 2.0, 3.0), 4.0);
		FSphere3f Copied(FromCenter);
		FSphere DoubleSphere(FVector(0.0, 0.0, 0.0), 2.0);
		FSphere3f FromDouble(DoubleSphere);
		TArray<FVector3f> Points;
		Points.Add(FVector3f::ZeroVector);
		Points.Add(FVector3f(2.0, 0.0, 0.0));
		FSphere3f FromPoints(Points);
		FromCenter.W = 0.0;
		return DefaultSphere.W == 0.0 && DefaultSphere.Center.Equals(FVector3f::ZeroVector) && Copied.W == 4.0 && Copied.Center.X == 1.0 && FromDouble.W == 2.0 && FromPoints.W > 0.0;
	}

	// FSphere3f.W. Input center (1,2,3) radius 4. W is 4. Field read; radius is W.
	bool Observe_Surface006_Nominal()
	{
		FSphere3f Sphere(FVector3f(1.0, 2.0, 3.0), 4.0);
		return Sphere.W == 4.0;
	}

	// FSphere3f.Center. Input center (1,2,3) radius 4. Center is (1,2,3).
	// Field read; no mutation.
	bool Observe_Surface007_Nominal()
	{
		FSphere3f Sphere(FVector3f(1.0, 2.0, 3.0), 4.0);
		return Sphere.Center.X == 1.0 && Sphere.Center.Y == 2.0 && Sphere.Center.Z == 3.0;
	}

	// FSphere3f.Intersects. Inputs origin radius 2 vs overlap at X=3 radius 2
	// and disjoint at X=10 radius 1. Overlap is true; disjoint is false.
	// Query; neither sphere mutates.
	bool Observe_Intersects_Nominal()
	{
		FSphere3f Sphere(FVector3f::ZeroVector, 2.0);
		FSphere3f Overlap(FVector3f(3.0, 0.0, 0.0), 2.0);
		FSphere3f Disjoint(FVector3f(10.0, 0.0, 0.0), 1.0);
		return Sphere.Intersects(Overlap) && Sphere.Intersects(Overlap, KINDA_SMALL_NUMBER) && !Sphere.Intersects(Disjoint);
	}
}
/** @end */
