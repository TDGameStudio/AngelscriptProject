// Purpose: Observe FPlane4f origin and normal queries, including normal
// aliasing onto XYZ.
// AS-facing API: FVector3f FPlane4f.GetOrigin() const;
// const FVector3f& FPlane4f.GetNormal() const;
// Inputs: Plane through (0,0,5) with normal (0,0,1), a through-origin
// companion, and a write to Plane.Z after taking the normal reference.
// Expected observations: Origin is (0,0,5). Normal is (0,0,1) and matches
// XYZ. Writing Plane.Z is visible through the returned normal reference.
// Boundary/ownership: GetOrigin returns a point copy. GetNormal aliases the
// XYZ normal; W is the plane distance.

namespace TS_FPlane4f_Queries_01
{
	bool Observe_GetOrigin_Nominal()
	{
		FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
		FVector3f Origin = Plane.GetOrigin();
		FPlane4f ThroughOrigin(FVector3f::ZeroVector, FVector3f(0, 0, 1));
		FVector3f OriginAtZero = ThroughOrigin.GetOrigin();
		return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 5.0 && OriginAtZero.Z == 0.0;
	}

	bool Observe_GetNormal_Nominal()
	{
		FPlane4f Plane(FVector3f(0, 0, 5), FVector3f(0, 0, 1));
		const FVector3f& Normal = Plane.GetNormal();
		bool bMatchesXyz = Normal.X == Plane.X && Normal.Y == Plane.Y && Normal.Z == Plane.Z;
		bool bUnitZ = Normal.X == 0.0 && Normal.Y == 0.0 && Normal.Z == 1.0;
		Plane.Z = -1.0;
		bool bAliased = Normal.Z == Plane.Z && Normal.Z == -1.0;
		return bMatchesXyz && bUnitZ && bAliased;
	}
}
