/**
 * @version v1
 * @summary Observe FVector2D SizeSquared, in-place Normalize, distances, and InitFromString success/failure.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2D SizeSquared, in-place Normalize, distances, and InitFromString success/failure.
 * @topic Baseline
 */
// UE text "X=1 Y=2", empty text, omitted SMALL_NUMBER default.
// Expected observations: SizeSquared of (3,4) is 25. Normalize of (3,0)
// yields (1,0). Normalize of zero yields zero. Distance is 5. DistSquared
// is 25. InitFromString true parses (1,2); empty returns false.
// Boundary/ownership: Normalize is void and mutates. InitFromString mutates.
// Distance helpers do not mutate.

namespace TS_FVector2D_Behavior_02
{
	bool Observe_SizeSquared_Nominal()
	{
		return FVector2D(3, 4).SizeSquared() == 25.0 && FVector2D(0, 0).SizeSquared() == 0.0;
	}

	bool Observe_Normalize_Nominal()
	{
		FVector2D Vector(3, 0);
		Vector.Normalize();
		FVector2D Zero;
		Zero.Normalize();
		return Vector.Equals(FVector2D(1, 0)) && Zero.IsZero();
	}

	bool Observe_Distance_Nominal()
	{
		return FVector2D(0, 0).Distance(FVector2D(3, 4)) == 5.0 && FVector2D(1, 1).Distance(FVector2D(1, 1)) == 0.0;
	}

	bool Observe_DistSquared_Nominal()
	{
		return FVector2D(0, 0).DistSquared(FVector2D(3, 4)) == 25.0;
	}

	bool Observe_InitFromString_Nominal()
	{
		FVector2D Parsed;
		bool bValid = Parsed.InitFromString("X=1 Y=2");
		FVector2D EmptyTarget(9, 9);
		bool bEmpty = EmptyTarget.InitFromString("");
		return bValid && Parsed.Equals(FVector2D(1, 2)) && !bEmpty;
	}
}
/** @end */
