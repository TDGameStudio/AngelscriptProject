/**
 * @version v1
 * @summary Observe FVector3f projections onto vectors/normals, Euler unwind, heading, point-near tests, and distances.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f projections onto vectors/normals, Euler unwind, heading, point-near tests, and distances.
 * @topic Baseline
 */
// PointsAreSame; PointsAreNear; Distance; DistSquared; Dist2D; DistXY.
// Inputs: (2,2,0) onto X and Y, Euler (370,0,-190), Forward/Right heading,
// identical and far points, Dist 2, (0,0,0) to (3,4,12).
// Expected observations: ProjectOnTo X keeps (2,0,0). Unwind maps 370 to 10
// and -190 to 170. Forward heading is 0. Right heading is __HALF_PI_flt.
// Same points are same; far points are not near Dist 2. Distance of
// (3,4,12) is 13. DistSquared is 169. Dist2D and DistXY are 5.
// Boundary/ownership: UnwindEuler mutates degree components. DistXY aliases
// Dist2D.

namespace TS_FVector3f_Behavior_04
{
	bool Observe_ProjectOnTo_Nominal()
	{
		FVector3f Projected = FVector3f(2.0f, 2.0f, 0.0f).ProjectOnTo(FVector3f(1.0f, 0.0f, 0.0f));
		return Projected.Equals(FVector3f(2.0f, 0.0f, 0.0f));
	}

	bool Observe_ProjectOnToNormal_Nominal()
	{
		FVector3f Projected = FVector3f(2.0f, 2.0f, 0.0f).ProjectOnToNormal(FVector3f(0.0f, 1.0f, 0.0f));
		return Projected.Equals(FVector3f(0.0f, 2.0f, 0.0f));
	}

	bool Observe_UnwindEuler_Nominal()
	{
		FVector3f Euler(370.0f, 0.0f, -190.0f);
		Euler.UnwindEuler();
		return Euler.Equals(FVector3f(10.0f, 0.0f, 170.0f));
	}

	bool Observe_HeadingAngle_Nominal()
	{
		float32 Forward = FVector3f::ForwardVector.HeadingAngle();
		float32 Right = FVector3f::RightVector.HeadingAngle();
		return Forward == 0.0f && Right == __HALF_PI_flt;
	}

	bool Observe_PointsAreSame_Nominal()
	{
		return FVector3f(1.0f, 2.0f, 3.0f).PointsAreSame(FVector3f(1.0f, 2.0f, 3.0f)) && !FVector3f(1.0f, 2.0f, 3.0f).PointsAreSame(FVector3f(10.0f, 0.0f, 0.0f));
	}

	bool Observe_PointsAreNear_Nominal()
	{
		bool bNear = FVector3f(0.0f, 0.0f, 0.0f).PointsAreNear(FVector3f(1.0f, 1.0f, 1.0f), 2.0f);
		bool bFar = FVector3f(0.0f, 0.0f, 0.0f).PointsAreNear(FVector3f(3.0f, 0.0f, 0.0f), 2.0f);
		return bNear && !bFar;
	}

	bool Observe_Distance_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).Distance(FVector3f(3.0f, 4.0f, 12.0f)) == 13.0f && FVector3f(1.0f, 2.0f, 3.0f).Distance(FVector3f(1.0f, 2.0f, 3.0f)) == 0.0f;
	}

	bool Observe_DistSquared_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).DistSquared(FVector3f(3.0f, 4.0f, 12.0f)) == 169.0f;
	}

	bool Observe_Dist2D_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).Dist2D(FVector3f(3.0f, 4.0f, 12.0f)) == 5.0f && FVector3f(0.0f, 0.0f, 9.0f).Dist2D(FVector3f(0.0f, 0.0f, 1.0f)) == 0.0f;
	}

	bool Observe_DistXY_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).DistXY(FVector3f(3.0f, 4.0f, 12.0f)) == 5.0f;
	}
}
/** @end */
