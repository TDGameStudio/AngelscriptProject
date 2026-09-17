/**
 * @version v1
 * @summary Observe FBox center/extent/volume queries, closest-point, equals with tolerance, and inside tests. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox center/extent/volume queries, closest-point, equals with tolerance, and inside tests. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// GetClosestPointTo, Equals, IsInside(point), IsInsideOrOn(point),
// IsInside(box), IsInsideXY(point).
// Inputs: Box (0,0,0)-(2,2,2), interior point (1,1,1), on-face (0,1,1),
// exterior (3,1,1), a contained smaller box, and KINDA_SMALL_NUMBER.
// Expected observations: Center is (1,1,1), extent is (1,1,1), volume is 8.
// Closest point of (3,1,1) lies on the box. Interior IsInside true; exterior
// false. On-face IsInsideOrOn true.
// Boundary/ownership: Out Center/Extents are writebacks. Equals uses
// tolerance, unlike operator==.

namespace TS_FBox_Queries_01
{
	bool Observe_GetCenter_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Center = Box.GetCenter();
		return Center.X == 1.0 && Center.Y == 1.0 && Center.Z == 1.0;
	}

	bool Observe_GetExtent_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Extent = Box.GetExtent();
		return Extent.X == 1.0 && Extent.Y == 1.0 && Extent.Z == 1.0;
	}

	bool Observe_GetVolume_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Flat(FVector(0, 0, 0), FVector(2, 2, 0));
		return Box.GetVolume() == 8.0 && Flat.GetVolume() == 0.0;
	}

	bool Observe_GetCenterAndExtents_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Center = FVector::ZeroVector;
		FVector Extents = FVector::ZeroVector;
		Box.GetCenterAndExtents(Center, Extents);
		return Center.X == 1.0 && Extents.X == 1.0;
	}

	bool Observe_GetClosestPointTo_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FVector Inside = Box.GetClosestPointTo(FVector(1, 1, 1));
		FVector Outside = Box.GetClosestPointTo(FVector(3, 1, 1));
		return Inside.X == 1.0 && Outside.X == 2.0;
	}

	bool Observe_Equals_Nominal()
	{
		FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Right(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Perturbed(FVector(0, 0, 0), FVector(1.0 + KINDA_SMALL_NUMBER * 0.5, 1, 1));
		return Left.Equals(Right) && Left.Equals(Perturbed);
	}

	bool Observe_IsInside_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		FBox Inner(FVector(0.5, 0.5, 0.5), FVector(1.5, 1.5, 1.5));
		return Box.IsInside(FVector(1, 1, 1)) && !Box.IsInside(FVector(3, 1, 1)) && Box.IsInside(Inner);
	}

	bool Observe_IsInsideOrOn_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		return Box.IsInsideOrOn(FVector(0, 1, 1)) && !Box.IsInsideOrOn(FVector(3, 1, 1));
	}

	bool Observe_IsInsideXY_Nominal()
	{
		FBox Box(FVector(0, 0, 0), FVector(2, 2, 2));
		return Box.IsInsideXY(FVector(1, 1, 9)) && !Box.IsInsideXY(FVector(3, 1, 1));
	}
}
/** @end */
