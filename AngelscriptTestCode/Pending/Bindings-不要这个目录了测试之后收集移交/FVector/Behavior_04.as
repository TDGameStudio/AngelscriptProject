/**
 * @version v1
 * @summary Observe FVector plane/axis projection, 2D cosine, Euler unwind, heading, and point-near tests plus Distance.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector plane/axis projection, 2D cosine, Euler unwind, heading, and point-near tests plus Distance.
 * @topic Baseline
 */
// ProjectOnTo; ProjectOnToNormal; UnwindEuler; HeadingAngle; PointsAreSame;
// PointsAreNear; Distance.
// Inputs: (1,2,3) onto Z plane, (1,0,0) rotated 90 deg about Z, XY (1,0,*)
// vs (0,1,*), (2,2,0) onto X and Y normals, Euler (370,0,-190), heading
// Forward/Right, identical and far points, Dist 2, (0,0,0) to (3,4,12).
// Expected observations: Plane project drops Z. 90 deg about Z maps X to Y.
// Cosine of aligned XY is 1 and of perpendicular XY is 0. ProjectOnTo X keeps
// (2,0,0). Unwind maps 370 to 10. Forward heading is 0. Right heading is
// HALF_PI. Same points are same; far points are not near Dist 2. Distance
// of (3,4,12) is 13.
// Boundary/ownership: UnwindEuler mutates degree components. RotateAngleAxis
// returns a new vector. Plane normal should be unit.

namespace TS_FVector_Behavior_04
{
	bool Observe_VectorPlaneProject_Nominal()
	{
		FVector Projected = FVector(1, 2, 3).VectorPlaneProject(FVector(0, 0, 1));
		return Projected.Equals(FVector(1, 2, 0));
	}

	bool Observe_RotateAngleAxis_Nominal()
	{
		FVector Rotated = FVector(1, 0, 0).RotateAngleAxis(90.0, FVector(0, 0, 1));
		return Rotated.Equals(FVector(0, 1, 0));
	}

	bool Observe_CosineAngle2D_Nominal()
	{
		float64 Aligned = FVector(1, 0, 5).CosineAngle2D(FVector(1, 0, 9));
		float64 Perp = FVector(1, 0, 0).CosineAngle2D(FVector(0, 1, 0));
		return Aligned == 1.0 && Perp == 0.0;
	}

	bool Observe_ProjectOnTo_Nominal()
	{
		FVector Projected = FVector(2, 2, 0).ProjectOnTo(FVector(1, 0, 0));
		return Projected.Equals(FVector(2, 0, 0));
	}

	bool Observe_ProjectOnToNormal_Nominal()
	{
		FVector Projected = FVector(2, 2, 0).ProjectOnToNormal(FVector(0, 1, 0));
		return Projected.Equals(FVector(0, 2, 0));
	}

	bool Observe_UnwindEuler_Nominal()
	{
		FVector Euler(370, 0, -190);
		Euler.UnwindEuler();
		return Euler.Equals(FVector(10, 0, 170));
	}

	bool Observe_HeadingAngle_Nominal()
	{
		return FVector::ForwardVector.HeadingAngle() == 0.0 && FVector::RightVector.HeadingAngle() == HALF_PI;
	}

	bool Observe_PointsAreSame_Nominal()
	{
		return FVector(1, 2, 3).PointsAreSame(FVector(1, 2, 3)) && !FVector(1, 2, 3).PointsAreSame(FVector(10, 0, 0));
	}

	bool Observe_PointsAreNear_Nominal()
	{
		return FVector(0, 0, 0).PointsAreNear(FVector(1, 1, 1), 2.0) &&
			!FVector(0, 0, 0).PointsAreNear(FVector(3, 0, 0), 2.0);
	}

	bool Observe_Distance_Nominal()
	{
		return FVector(0, 0, 0).Distance(FVector(3, 4, 12)) == 13.0 && FVector(1, 2, 3).Distance(FVector(1, 2, 3)) == 0.0;
	}
}
/** @end */
