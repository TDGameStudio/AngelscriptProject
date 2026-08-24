// Purpose: Observe FVector2D.GetClampedToMaxSize for long, short, and zero
// vectors.
// AS-facing API: FVector2D FVector2D.GetClampedToMaxSize(float64 Max) const;
// Inputs: (10,0) Max 5, (1,0) Max 5, zero Max 5.
// Expected observations: (10,0) clamps to length 5. (1,0) is unchanged.
// Zero stays zero.
// Boundary/ownership: Returns a copy. Max is a length, not a per-component
// clamp.

namespace TS_FVector2D_Queries_02
{
	bool Observe_GetClampedToMaxSize_Nominal()
	{
		FVector2D Long = FVector2D(10, 0).GetClampedToMaxSize(5.0);
		FVector2D Short = FVector2D(1, 0).GetClampedToMaxSize(5.0);
		FVector2D Zero = FVector2D(0, 0).GetClampedToMaxSize(5.0);
		return Long.Equals(FVector2D(5, 0)) && Short.Equals(FVector2D(1, 0)) && Zero.IsZero();
	}
}
