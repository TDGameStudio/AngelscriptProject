/**
 * @version v1
 * @summary Observe FPlane4f constructors and signed PlaneDot.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FPlane4f constructors and signed PlaneDot.
 * @topic Baseline
 */
// FPlane4f Plane(const FVector3f& PointA, const FVector3f& PointB, const FVector3f& PointC);
// FPlane4f Plane(const FPlane& Plane);
// float32 FPlane4f.PlaneDot(const FVector3f& Location) const;
// Inputs: Point+normal (0,0,5)/(0,0,1), three-point XY plane, FPlane
// conversion, on-plane (0,0,5), above (0,0,6), and below (0,0,4).
// Expected observations: Point+normal preserves unit Z and origin Z=5.
// Three-point XY plane has Z=1. Conversion from FPlane preserves Z and W.
// PlaneDot is 0 on the plane, positive above, negative below.
// Boundary/ownership: Constructors copy values. PlaneDot does not mutate
// the plane. XYZ is the normal and W is distance.

namespace TS_FPlane4f_Behavior_01
{
	bool Observe_Plane_Nominal()
	{
		FPlane4f FromPointNormal(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
		FPlane4f FromPoints(FVector3f(0, 0, 0), FVector3f(1, 0, 0), FVector3f(0, 1, 0));
		FPlane DoublePlane(FVector(0, 0, 5), FVector(0, 0, 1));
		FPlane4f FromDouble(DoublePlane);
		FVector3f Normal = FromPointNormal.GetNormal();
		FVector3f Origin = FromPointNormal.GetOrigin();
		bool bPointNormal = Normal.Z == 1.0 && Origin.Z == 5.0;
		bool bThreePoints = FromPoints.GetNormal().Z == 1.0;
		bool bFromDouble = FromDouble.GetNormal().Z == 1.0 && FromDouble.GetOrigin().Z == 5.0;
		return bPointNormal && bThreePoints && bFromDouble;
	}

	bool Observe_PlaneDot_Nominal()
	{
		FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
		float32 OnPlane = Plane.PlaneDot(FVector3f(0, 0, 5));
		float32 Above = Plane.PlaneDot(FVector3f(0, 0, 6));
		float32 Below = Plane.PlaneDot(FVector3f(0, 0, 4));
		return OnPlane == 0.0 && Above > 0.0 && Below < 0.0;
	}
}
/** @end */
