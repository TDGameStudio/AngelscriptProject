/**
 * @version v1
 * @summary FPlane4f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPlane4f
 *
 * plane
 * plane-dot
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
 * @covers FPlane4f.plane
 * @inputs FPlane4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FPlane4f Plane(const FVector3f& PointA, const FVector3f& PointB, const FVector3f& PointC);
// FPlane4f Plane(const FPlane& Plane);
// float32 FPlane4f.PlaneDot(const FVector3f& Location) const;
// Inputs: Point+normal (0,0,5)/(0,0,1), three-point XY plane, FPlane
// conversion, on-plane (0,0,5), above (0,0,6), and below (0,0,4).
// Expected observations: Point+normal preserves unit Z and origin Z=5.
// Three-point XY plane has Z=1. Conversion from FPlane preserves Z and W.
// PlaneDot is 0 on the plane, positive above, negative below.
// Boundary/ownership: Constructors copy values. PlaneDot does not mutate
// the plane. XYZ is the normal and W is distance.
bool ObservePlaneNominal()
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
/** @end */
/**
 * @begin plane-dot
 * @summary the plane.
 * @topic Unreal
 */
/**
 * @function ObservePlaneDotNominal
 * @summary the plane.
 * @covers FPlane4f.plane-dot
 * @inputs FPlane4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePlaneDotNominal()
{
	FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
	float32 OnPlane = Plane.PlaneDot(FVector3f(0, 0, 5));
	float32 Above = Plane.PlaneDot(FVector3f(0, 0, 6));
	float32 Below = Plane.PlaneDot(FVector3f(0, 0, 4));
	return OnPlane == 0.0 && Above > 0.0 && Below < 0.0;
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
 * @covers FPlane4f.get-origin
 * @inputs FPlane4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Plane through (0,0,5) with normal (0,0,1), a through-origin
// companion, and a write to Plane.Z after taking the normal reference.
// Expected observations: Origin is (0,0,5). Normal is (0,0,1) and matches
// XYZ. Writing Plane.Z is visible through the returned normal reference.
// Boundary/ownership: GetOrigin returns a point copy. GetNormal aliases the
// XYZ normal; W is the plane distance.
bool ObserveGetOriginNominal()
{
	FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
	FVector3f Origin = Plane.GetOrigin();
	FPlane4f ThroughOrigin(FVector3f::ZeroVector, FVector3f(0, 0, 1));
	FVector3f OriginAtZero = ThroughOrigin.GetOrigin();
	return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 5.0 && OriginAtZero.Z == 0.0;
}
/** @end */
/**
 * @begin get-normal
 * @summary XYZ normal.
 * @topic Unreal
 */
/**
 * @function ObserveGetNormalNominal
 * @summary XYZ normal.
 * @covers FPlane4f.get-normal
 * @inputs FPlane4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveGetNormalNominal()
{
	FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
	const FVector3f& Normal = Plane.GetNormal();
	bool bMatchesXyz = Normal.X == Plane.X && Normal.Y == Plane.Y && Normal.Z == Plane.Z;
	bool bUnitZ = Normal.X == 0.0 && Normal.Y == 0.0 && Normal.Z == 1.0;
	Plane.Z = -1.0;
	bool bAliased = Normal.Z == Plane.Z && Normal.Z == -1.0;
	return bMatchesXyz && bUnitZ && bAliased;
}
/** @end */
