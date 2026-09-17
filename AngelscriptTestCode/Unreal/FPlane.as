/**
 * @version v1
 * @summary FPlane host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPlane
 *
 * plane
 * plane-dot
 * ray-plane-intersection
 * segment-plane-intersection
 * get-origin
 * get-normal
 */
/**
 * @begin plane
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObservePlaneNominal
 * @summary Observe the container API.
 * @covers FPlane.plane
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FPlane Plane(const FVector& PointA, const FVector& PointB, const FVector& PointC);
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
bool ObservePlaneNominal()
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
/** @end */
/**
 * @begin plane-dot
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @topic Unreal
 */
/**
 * @function ObservePlaneDotNominal
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @covers FPlane.plane-dot
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePlaneDotNominal()
{
	FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
	float64 OnPlane = Plane.PlaneDot(FVector(0, 0, 5));
	float64 Above = Plane.PlaneDot(FVector(0, 0, 6));
	float64 Below = Plane.PlaneDot(FVector(0, 0, 4));
	return OnPlane == 0.0 && Above > 0.0 && Below < 0.0;
}
/** @end */
/**
 * @begin ray-plane-intersection
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @topic Unreal
 */
/**
 * @function ObserveRayPlaneIntersectionNominal
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @covers FPlane.ray-plane-intersection
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRayPlaneIntersectionNominal()
{
	FPlane Plane(FVector::ZeroVector, FVector(0, 0, 1));
	FVector Hit = Plane.RayPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, -1));
	FVector OffsetHit = Plane.RayPlaneIntersection(FVector(2, 3, 4), FVector(0, 0, -1));
	return Hit.X == 0.0 && Hit.Y == 0.0 && Hit.Z == 0.0 && OffsetHit.X == 2.0 && OffsetHit.Y == 3.0 && OffsetHit.Z == 0.0;
}
/** @end */
/**
 * @begin segment-plane-intersection
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @topic Unreal
 */
/**
 * @function ObserveSegmentPlaneIntersectionNominal
 * @summary OutIntersectionPoint is written when the segment reports true.
 * @covers FPlane.segment-plane-intersection
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSegmentPlaneIntersectionNominal()
{
	FPlane Plane(FVector::ZeroVector, FVector(0, 0, 1));
	FVector CrossingHit = FVector::ZeroVector;
	bool bCrossing = Plane.SegmentPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, -1), CrossingHit);
	FVector MissHit = FVector(9, 9, 9);
	bool bMiss = Plane.SegmentPlaneIntersection(FVector(0, 0, 1), FVector(0, 0, 2), MissHit);
	return bCrossing && CrossingHit.Z == 0.0 && !bMiss;
}
/** @end */
/**
 * @begin get-origin
 * @summary Inputs:
 * @topic Unreal
 */
/**
 * @function ObserveGetOriginNominal
 * @summary Inputs:
 * @covers FPlane.get-origin
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Plane through (0,0,5) with normal (0,0,1), a default-unrelated
// second plane through the origin, and a write to Plane.Z after taking the
// normal reference.
// Expected observations: Origin is (0,0,5). Normal is (0,0,1) and matches
// XYZ. Writing Plane.Z is visible through the returned normal reference.
// Boundary/ownership: GetOrigin returns a point copy. GetNormal aliases the
// XYZ normal stored on the plane; W is the plane distance.
bool ObserveGetOriginNominal()
{
	FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
	FVector Origin = Plane.GetOrigin();
	FPlane ThroughOrigin(FVector::ZeroVector, FVector(0, 0, 1));
	FVector OriginAtZero = ThroughOrigin.GetOrigin();
	return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 5.0 && OriginAtZero.Z == 0.0 && Plane.W == 5.0;
}
/** @end */
/**
 * @begin get-normal
 * @summary XYZ normal stored on the plane.
 * @topic Unreal
 */
/**
 * @function ObserveGetNormalNominal
 * @summary XYZ normal stored on the plane.
 * @covers FPlane.get-normal
 * @inputs FPlane values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveGetNormalNominal()
{
	FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
	const FVector& Normal = Plane.GetNormal();
	bool bMatchesXyz = Normal.X == Plane.X && Normal.Y == Plane.Y && Normal.Z == Plane.Z;
	bool bUnitZ = Normal.X == 0.0 && Normal.Y == 0.0 && Normal.Z == 1.0;
	Plane.Z = -1.0;
	bool bAliased = Normal.Z == Plane.Z && Normal.Z == -1.0;
	return bMatchesXyz && bUnitZ && bAliased;
}
/** @end */
