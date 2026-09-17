/**
 * @version v1
 * @summary Observe FBox constructors, Min/Max fields, inverse/forward transform, and intersection/overlap tests. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox constructors, Min/Max fields, inverse/forward transform, and intersection/overlap tests. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// FBox Box(const FBox3f& Box); FVector Box.Min; FVector Box.Max;
// InverseTransformBy; TransformBy; Intersect; IntersectXY; Overlap.
// Inputs: Default/invalid box, (0,0,0)-(2,2,2), FBox3f conversion, identity
// transform, overlapping and disjoint neighbors.
// Expected observations: Corner constructor stores Min/Max. Identity
// transform preserves the box. Overlapping Intersect is true; disjoint is
// false. Overlap of overlapping boxes has positive volume.
// Boundary/ownership: Default Box() is invalid/force-initialized. Transform
// returns a new box.

namespace TS_FBox_Behavior_01
{
	// FBox() default, corner (0,0,0)-(2,2,2), and FBox3f conversion. Oracle: stored Min/Max and converted Max.X==1. Value type.
	bool Observe_Box_Nominal()
	{
		FBox DefaultBox;
		FBox Corners(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox3f Single(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FBox FromSingle(Single);
		return Corners.Min.X == 0.0 && Corners.Max.X == 2.0 && FromSingle.Max.X == 1.0 && !(DefaultBox == Corners);
	}

	// FBox.Min on (0,0,0)-(2,2,2). Oracle: Min.X==0. Field read does not mutate.
	bool Observe_Surface004_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Min = Box.Min;
		return Min.X == 0.0 && Box.Min.X == 0.0;
	}

	// FBox.Max on (0,0,0)-(2,2,2). Oracle: Max.X==2. Field read does not mutate.
	bool Observe_Surface005_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Max = Box.Max;
		return Max.X == 2.0 && Box.Max.X == 2.0;
	}

	// InverseTransformBy(Identity) on (0,0,0)-(2,2,2). Oracle: corners preserved. Returns a new box.
	bool Observe_InverseTransformBy_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Inverted = Box.InverseTransformBy(FTransform::Identity);
		return Inverted.Min.X == 0.0 && Inverted.Max.X == 2.0 && Box.Min.X == 0.0;
	}

	// TransformBy(Identity) on (0,0,0)-(2,2,2). Oracle: corners preserved. Returns a new box.
	bool Observe_TransformBy_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Transformed = Box.TransformBy(FTransform::Identity);
		return Transformed.Min.X == 0.0 && Transformed.Max.X == 2.0 && Box.Min.X == 0.0;
	}

	// Intersect overlapping (1,1,1)-(3,3,3) vs disjoint (5,5,5)-(6,6,6). Oracle: true then false. No mutation.
	bool Observe_Intersect_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Overlap(FVector(1, 1, 1), FVector(3, 3, 3));
		FBox Disjoint(FVector(5, 5, 5), FVector(6, 6, 6));
		return Box.Intersect(Overlap) && !Box.Intersect(Disjoint);
	}

	// IntersectXY overlapping XY (1,1,9)-(3,3,10) vs disjoint XY. Oracle: true then false. Z ignored.
	bool Observe_IntersectXY_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox OverlapXY(FVector(1, 1, 9), FVector(3, 3, 10));
		FBox DisjointXY(FVector(5, 5, 0), FVector(6, 6, 1));
		return Box.IntersectXY(OverlapXY) && !Box.IntersectXY(DisjointXY);
	}

	// Overlap of (0,0,0)-(2,2,2) and (1,1,1)-(3,3,3). Oracle: volume > 0. Returns a new box.
	bool Observe_Overlap_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Other(FVector(1, 1, 1), FVector(3, 3, 3));
		FBox Overlap = Box.Overlap(Other);
		return Overlap.GetVolume() > 0.0 && Box.GetVolume() == 8.0;
	}
}
/** @end */
