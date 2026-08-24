// Purpose: Observe FRotator3f zero tests, inverse, normalization, winding
// split, Manhattan distance, and NaN.
// AS-facing API: IsNearlyZero; IsZero; Equals; GetInverse; GetNormalized;
// GetDenormalized; GetWindingAndRemainder; GetManhattanDistance; ContainsNaN.
// Inputs: ZeroRotator, (10,0,0), (0,270,0), (0,370,0), default-omitted
// __KINDA_SMALL_NUMBER_flt, and a self comparison.
// Expected observations: Zero is zero and nearly zero. Normalized 270 yaw is
// -90. Denormalized -90 is 270. Winding of 370 is 360 with remainder 10.
// Manhattan distance to zero is 60. ContainsNaN is false.
// Boundary/ownership: Winding and Remainder are writebacks. Queries do not
// mutate the receiver except through those out parameters.

namespace TS_FRotator3f_Queries_01
{
	bool Observe_IsNearlyZero_Nominal()
	{
		FRotator3f Zero = FRotator3f::ZeroRotator;
		FRotator3f Offset(10.0, 0.0, 0.0);
		return Zero.IsNearlyZero() && Zero.IsNearlyZero(__KINDA_SMALL_NUMBER_flt) && !Offset.IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		FRotator3f Zero;
		FRotator3f Offset(10.0, 0.0, 0.0);
		return Zero.IsZero() && !Offset.IsZero();
	}

	bool Observe_Equals_Nominal()
	{
		FRotator3f Left(10.0, 20.0, 30.0);
		FRotator3f Right(10.0, 20.0, 30.0);
		FRotator3f Different(10.0, 90.0, 30.0);
		return Left.Equals(Right) && Left.Equals(Right, __KINDA_SMALL_NUMBER_flt) && !Left.Equals(Different);
	}

	bool Observe_GetInverse_Nominal()
	{
		FRotator3f Yaw90(0.0, 90.0, 0.0);
		FRotator3f Inverse = Yaw90.GetInverse();
		FRotator3f RoundTrip = Inverse.GetInverse();
		return Inverse.Equals(FRotator3f(0.0, -90.0, 0.0)) && RoundTrip.Equals(Yaw90);
	}

	bool Observe_GetNormalized_Nominal()
	{
		FRotator3f Over(0.0, 270.0, 0.0);
		FRotator3f Normalized = Over.GetNormalized();
		return Normalized.Yaw == -90.0 && Over.Yaw == 270.0;
	}

	bool Observe_GetDenormalized_Nominal()
	{
		FRotator3f Signed(0.0, -90.0, 0.0);
		FRotator3f Denormalized = Signed.GetDenormalized();
		return Denormalized.Yaw == 270.0 && Signed.Yaw == -90.0;
	}

	bool Observe_GetWindingAndRemainder_Nominal()
	{
		FRotator3f Over(0.0, 370.0, 0.0);
		FRotator3f Winding;
		FRotator3f Remainder;
		Over.GetWindingAndRemainder(Winding, Remainder);
		return Winding.Yaw == 360.0 && Remainder.Yaw == 10.0 && Over.Yaw == 370.0;
	}

	bool Observe_GetManhattanDistance_Nominal()
	{
		FRotator3f Rotator(10.0, 20.0, 30.0);
		float32 ToZero = Rotator.GetManhattanDistance(FRotator3f::ZeroRotator);
		float32 ToSelf = Rotator.GetManhattanDistance(Rotator);
		return ToZero == 60.0 && ToSelf == 0.0;
	}

	bool Observe_ContainsNaN_Nominal()
	{
		FRotator3f Finite(10.0, 20.0, 30.0);
		FRotator3f Zero;
		return !Finite.ContainsNaN() && !Zero.ContainsNaN();
	}
}
