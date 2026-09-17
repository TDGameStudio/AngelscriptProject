/**
 * @version v1
 * @summary Observe FPlane origin and normal queries, including normal aliasing onto XYZ.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FPlane origin and normal queries, including normal aliasing onto XYZ.
 * @topic Baseline
 */
// const FVector& Plane.GetNormal() const;
// Inputs: Plane through (0,0,5) with normal (0,0,1), a default-unrelated
// second plane through the origin, and a write to Plane.Z after taking the
// normal reference.
// Expected observations: Origin is (0,0,5). Normal is (0,0,1) and matches
// XYZ. Writing Plane.Z is visible through the returned normal reference.
// Boundary/ownership: GetOrigin returns a point copy. GetNormal aliases the
// XYZ normal stored on the plane; W is the plane distance.

namespace TS_FPlane_Queries_01
{
	bool Observe_GetOrigin_Nominal()
	{
		FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
		FVector Origin = Plane.GetOrigin();
		FPlane ThroughOrigin(FVector::ZeroVector, FVector(0, 0, 1));
		FVector OriginAtZero = ThroughOrigin.GetOrigin();
		return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 5.0 && OriginAtZero.Z == 0.0 && Plane.W == 5.0;
	}

	bool Observe_GetNormal_Nominal()
	{
		FPlane Plane(FVector(0, 0, 5), FVector(0, 0, 1));
		const FVector& Normal = Plane.GetNormal();
		bool bMatchesXyz = Normal.X == Plane.X && Normal.Y == Plane.Y && Normal.Z == Plane.Z;
		bool bUnitZ = Normal.X == 0.0 && Normal.Y == 0.0 && Normal.Z == 1.0;
		Plane.Z = -1.0;
		bool bAliased = Normal.Z == Plane.Z && Normal.Z == -1.0;
		return bMatchesXyz && bUnitZ && bAliased;
	}
}
/** @end */
