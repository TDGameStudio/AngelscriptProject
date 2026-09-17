/**
 * @version v1
 * @summary Observe FVector2f Size/SizeSquared, in-place Normalize, distances, and InitFromString success/failure.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f Size/SizeSquared, in-place Normalize, distances, and InitFromString success/failure.
 * @topic Baseline
 */
// InitFromString.
// Inputs: (3,4) so Size is 5, zero for Normalize, (0,0) to (3,4), UE text
// "X=1 Y=2", empty text, omitted __SMALL_NUMBER_flt.
// Expected observations: Size of (3,4) is 5. SizeSquared is 25. Normalize of
// (3,0) yields (1,0). Normalize of zero yields zero. Distance is 5.
// DistSquared is 25. InitFromString true parses (1,2); empty returns false.
// Boundary/ownership: Normalize is void and mutates. InitFromString mutates.
// Components are float32.

namespace TS_FVector2f_Behavior_02
{
	bool Observe_Size_Nominal()
	{
		return FVector2f(3.0f, 4.0f).Size() == 5.0f && FVector2f(0.0f, 0.0f).Size() == 0.0f;
	}

	bool Observe_SizeSquared_Nominal()
	{
		return FVector2f(3.0f, 4.0f).SizeSquared() == 25.0f && FVector2f(0.0f, 0.0f).SizeSquared() == 0.0f;
	}

	bool Observe_Normalize_Nominal()
	{
		FVector2f Vector(3.0f, 0.0f);
		Vector.Normalize();
		FVector2f Zero;
		Zero.Normalize();
		return Vector.Equals(FVector2f(1.0f, 0.0f)) && Zero.IsZero();
	}

	bool Observe_Distance_Nominal()
	{
		return FVector2f(0.0f, 0.0f).Distance(FVector2f(3.0f, 4.0f)) == 5.0f &&
			FVector2f(1.0f, 1.0f).Distance(FVector2f(1.0f, 1.0f)) == 0.0f;
	}

	bool Observe_DistSquared_Nominal()
	{
		return FVector2f(0.0f, 0.0f).DistSquared(FVector2f(3.0f, 4.0f)) == 25.0f;
	}

	bool Observe_InitFromString_Nominal()
	{
		FVector2f Parsed;
		bool bValid = Parsed.InitFromString("X=1 Y=2");
		FVector2f EmptyTarget(9.0f, 9.0f);
		bool bEmpty = EmptyTarget.InitFromString("");
		return bValid && Parsed.Equals(FVector2f(1.0f, 2.0f)) && !bEmpty;
	}
}
/** @end */
