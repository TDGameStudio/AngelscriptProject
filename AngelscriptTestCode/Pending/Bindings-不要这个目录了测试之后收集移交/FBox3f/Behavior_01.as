/**
 * @version v1
 * @summary Observe FBox3f constructors, Min/Max fields, intersection, and inverse/forward transforms. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox3f constructors, Min/Max fields, intersection, and inverse/forward transforms. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// FBox3f Box(const FBox& Box); Min; Max; Intersect; InverseTransformBy;
// TransformBy(FTransform3f).
// Inputs: Default box, (0,0,0)-(2,2,2), FBox conversion, overlapping and
// disjoint neighbors, identity transforms.
// Expected observations: Conversion preserves 2.0 max. Identity transforms
// preserve corners. Overlapping Intersect is true.
// Boundary/ownership: Transform helpers return new boxes.

namespace TS_FBox3f_Behavior_01
{
	// FBox3f() default, corner (0,0,0)-(2,2,2), and FBox conversion. Oracle: Max.X==2 on both constructed boxes. Value type.
	bool Observe_Box_Nominal()
	{
		FBox3f DefaultBox;
		FBox3f Corners(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FBox DoubleBox(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox3f FromDouble(DoubleBox);
		return Corners.Max.X == 2.0 && FromDouble.Max.X == 2.0 && !(DefaultBox == Corners);
	}

	// FBox3f.Min on (0,0,0)-(2,2,2). Oracle: Min.X==0. Field read does not mutate.
	bool Observe_Surface005_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		return Box.Min.X == 0.0;
	}

	// FBox3f.Max on (0,0,0)-(2,2,2). Oracle: Max.X==2. Field read does not mutate.
	bool Observe_Surface006_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		return Box.Max.X == 2.0;
	}

	// Intersect overlapping (1,1,1)-(3,3,3) vs disjoint (5,5,5)-(6,6,6). Oracle: true then false. No mutation.
	bool Observe_Intersect_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FBox3f Overlap(FVector3f(1, 1, 1), FVector3f(3, 3, 3));
		FBox3f Disjoint(FVector3f(5, 5, 5), FVector3f(6, 6, 6));
		return Box.Intersect(Overlap) && !Box.Intersect(Disjoint);
	}

	// InverseTransformBy(Identity) on (0,0,0)-(2,2,2). Oracle: Max.X==2. Returns a new box.
	bool Observe_InverseTransformBy_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FBox3f Inverted = Box.InverseTransformBy(FTransform::Identity);
		return Inverted.Max.X == 2.0 && Box.Max.X == 2.0;
	}

	// TransformBy(FTransform3f::Identity) on (0,0,0)-(2,2,2). Oracle: Max.X==2. Returns a new box.
	bool Observe_TransformBy_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FBox3f Transformed = Box.TransformBy(FTransform3f::Identity);
		return Transformed.Max.X == 2.0 && Box.Max.X == 2.0;
	}
}
/** @end */
