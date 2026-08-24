// Purpose: Observe FSphere constructors, W/Center fields, intersection, and
// TransformBy.
// AS-facing API: Sphere(); Sphere(Center, Radius); Sphere(copy);
// Sphere(FSphere3f); Sphere(Points); W; Center; Intersects; TransformBy.
// Inputs: Default ForceInit sphere, center (1,2,3) radius 4, copy,
// FSphere3f conversion, two-point array, overlapping/disjoint neighbors,
// identity and translation transforms.
// Expected observations: Center/radius ctor stores Center and W. Default W is
// 0. Copy and FSphere3f convert. Points sphere radius is positive. Overlapping
// Intersects is true. Identity TransformBy preserves Center. Translation moves
// Center.X by 5.
// Boundary/ownership: Radius is W. TransformBy returns a new sphere.

namespace TS_FSphere_Behavior_01
{
	// FSphere constructors: default, center/radius, copy, FSphere3f, and
	// points. Inputs (1,2,3)/4, FSphere3f radius 2, and two points on X.
	// Default W is 0; copy stays 4 after mutating the source; points W > 0.
	// Copy is independent of later source mutation.
	bool Observe_Sphere_Nominal()
	{
		FSphere DefaultSphere;
		FSphere FromCenter(FVector(1.0, 2.0, 3.0), 4.0);
		FSphere Copied(FromCenter);
		FSphere3f Single(FVector3f(0.0, 0.0, 0.0), 2.0);
		FSphere FromSingle(Single);
		TArray<FVector> Points;
		Points.Add(FVector::ZeroVector);
		Points.Add(FVector(2.0, 0.0, 0.0));
		FSphere FromPoints(Points);
		FromCenter.W = 0.0;
		return DefaultSphere.W == 0.0 && DefaultSphere.Center.IsNearlyZero() && Copied.W == 4.0 && Copied.Center.X == 1.0 && FromSingle.W == 2.0 && FromPoints.W > 0.0;
	}

	// FSphere.W. Input center (1,2,3) radius 4. W is 4. Field read; radius is W.
	bool Observe_Surface006_Nominal()
	{
		FSphere Sphere(FVector(1.0, 2.0, 3.0), 4.0);
		return Sphere.W == 4.0;
	}

	// FSphere.Center. Input center (1,2,3) radius 4. Center is (1,2,3).
	// Field read; no mutation.
	bool Observe_Surface007_Nominal()
	{
		FSphere Sphere(FVector(1.0, 2.0, 3.0), 4.0);
		return Sphere.Center.X == 1.0 && Sphere.Center.Y == 2.0 && Sphere.Center.Z == 3.0;
	}

	// FSphere.Intersects. Inputs origin radius 2 vs overlap at X=3 radius 2
	// and disjoint at X=10 radius 1. Overlap is true with default and
	// KINDA_SMALL_NUMBER; disjoint is false. Query; neither sphere mutates.
	bool Observe_Intersects_Nominal()
	{
		FSphere Sphere(FVector::ZeroVector, 2.0);
		FSphere Overlap(FVector(3.0, 0.0, 0.0), 2.0);
		FSphere Disjoint(FVector(10.0, 0.0, 0.0), 1.0);
		return Sphere.Intersects(Overlap) && Sphere.Intersects(Overlap, KINDA_SMALL_NUMBER) && !Sphere.Intersects(Disjoint);
	}

	// FSphere.TransformBy. Inputs origin radius 2, Identity, and translation
	// +5 on X. Identity keeps Center.X 0 and W 2; translation sets Center.X 5.
	// Returns a new sphere; source Center.X stays 0.
	bool Observe_TransformBy_Nominal()
	{
		FSphere Sphere(FVector::ZeroVector, 2.0);
		FSphere Identity = Sphere.TransformBy(FTransform::Identity);
		FSphere Translated = Sphere.TransformBy(FTransform(FVector(5.0, 0.0, 0.0)));
		return Identity.Center.X == 0.0 && Identity.W == 2.0 && Translated.Center.X == 5.0 && Translated.W == 2.0 && Sphere.Center.X == 0.0;
	}
}
