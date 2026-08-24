// Purpose: Observe FBox3f center/extent/closest-point and inside tests.
// The bool return is the runner-readable oracle.
// AS-facing API: GetCenter, GetExtent, GetCenterAndExtents, GetClosestPointTo,
// IsInside, IsInsideOrOn.
// Inputs: Box (0,0,0)-(2,2,2), interior (1,1,1), on-face (0,1,1), exterior
// (3,1,1).
// Expected observations: Center/extent are (1,1,1). Closest exterior point
// clamps to 2. Interior IsInside true; on-face IsInsideOrOn true.
// Boundary/ownership: Out Center/Extents are writebacks.

namespace TS_FBox3f_Queries_01
{
	bool Observe_GetCenter_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FVector3f Center = Box.GetCenter();
		return Center.X == 1.0;
	}

	bool Observe_GetExtent_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FVector3f Extent = Box.GetExtent();
		return Extent.X == 1.0;
	}

	bool Observe_GetCenterAndExtents_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FVector3f Center;
		FVector3f Extents;
		Box.GetCenterAndExtents(Center, Extents);
		return Center.X == 1.0 && Extents.X == 1.0;
	}

	bool Observe_GetClosestPointTo_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		FVector3f Outside = Box.GetClosestPointTo(FVector3f(3, 1, 1));
		return Outside.X == 2.0;
	}

	bool Observe_IsInside_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		return Box.IsInside(FVector3f(1, 1, 1)) && !Box.IsInside(FVector3f(3, 1, 1));
	}

	bool Observe_IsInsideOrOn_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(2, 2, 2));
		return Box.IsInsideOrOn(FVector3f(0, 1, 1)) && !Box.IsInsideOrOn(FVector3f(3, 1, 1));
	}
}
