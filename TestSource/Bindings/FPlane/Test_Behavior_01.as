// Purpose: Observe FPlane constructors, signed PlaneDot, ray intersection,
// and finite segment intersection writeback.
// AS-facing API: FPlane Plane(const FVector& InLocation, const FVector& InNormal);
// FPlane Plane(const FVector& PointA, const FVector& PointB, const FVector& PointC);
// FPlane Plane(const FPlane4f& Plane);
// float64 Plane.PlaneDot(const FVector& Location) const;
// FVector Plane.RayPlaneIntersection(const FVector& RayOrigin, const FVector& RayDirection) const;
// bool Plane.SegmentPlaneIntersection(const FVector& StartPoint, const FVector& EndPoint, FVector& OutIntersectionPoint) const;
// Inputs: Point+normal (0,0,5)/(0,0,1), three-point XY plane, FPlane4f
// conversion, on-plane and off-plane locations, a non-parallel ray from
// (0,0,1) along -Z, a crossing segment, and a non-crossing segment.
// Expected observations: Point+normal stores XYZ as the normal and W as
// distance 5. PlaneDot is 0 on the plane, positive above it. The ray hits
// (0,0,0). Crossing segment returns true and writes the hit; the miss is
// false.
// Boundary/ownership: RayPlaneIntersection assumes a non-parallel ray.
// OutIntersectionPoint is written when the segment reports true.

namespace TS_FPlane_Behavior_01
{
	bool Observe_Plane_Nominal()
	{
		FPlane FromPointNormal(FVector(0, 0, 5), FVector(0, 0, 1));
		FPlane FromPoints(FVector(0, 0, 0), FVector(1, 0, 0), FVector(0, 1, 0));
		FPlane4f Single(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
		FPlane FromSingle(Single);
		bool bPointNormal = FromPointNormal.X == 0.0 && FromPointNormal.Z == 1.0 && FromPointNormal.W == 5.0;
		bool bThreePoints = FromPoints.Z == 1.0 && FromPoints.W == 0.0;
		bool bFromSingle = FromSingle.Z == 1.0 && FromSingle.W == 5.0;
		return bPointNormal && bThreePoints && bFromSingle;
	}

	bool Observe_PlaneDot_Nominal()
	{
		FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
		float64 OnPlane = Plane.PlaneDot(FVector(0, 0, 5));
		float64 Above = Plane.PlaneDot(FVector(0, 0, 6));
		float64 Below = Plane.PlaneDot(FVector(0, 0, 4));
		return OnPlane == 0.0 && Above > 0.0 && Below < 0.0;
	}

	bool Observe_RayPlaneIntersection_Nominal()
	{
		FPlane Plane(FVector::ZeroVector, FVector(0, 0, 1));
		FVector Hit = Plane.RayPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, -1));
		FVector OffsetHit = Plane.RayPlaneIntersection(FVector(2, 3, 4), FVector(0, 0, -1));
		return Hit.X == 0.0 && Hit.Y == 0.0 && Hit.Z == 0.0 && OffsetHit.X == 2.0 && OffsetHit.Y == 3.0 && OffsetHit.Z == 0.0;
	}

	bool Observe_SegmentPlaneIntersection_Nominal()
	{
		FPlane Plane(FVector::ZeroVector, FVector(0, 0, 1));
		FVector CrossingHit = FVector::ZeroVector;
		bool bCrossing = Plane.SegmentPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, -1), CrossingHit);
		FVector MissHit = FVector(9, 9, 9);
		bool bMiss = Plane.SegmentPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, 2), MissHit);
		return bCrossing && CrossingHit.Z == 0.0 && !bMiss;
	}
}
