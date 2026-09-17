/**
 * @version v1
 * @summary Observe FRotator zero tests, inverse, normalization, winding split, Manhattan distance, NaN, and the forward vector.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRotator zero tests, inverse, normalization, winding split, Manhattan distance, NaN, and the forward vector.
 * @topic Baseline
 */
// GetDenormalized; GetWindingAndRemainder; GetManhattanDistance; ContainsNaN;
// GetForwardVector.
// Inputs: ZeroRotator, (10,0,0), (0,270,0), (0,370,0), default-omitted
// tolerance, and KINDA_SMALL_NUMBER.
// Expected observations: Zero is zero and nearly zero. (10,0,0) is neither.
// GetNormalized of 270 yaw is -90. GetDenormalized of -90 is 270. Winding of
// 370 yaw is 360 with remainder 10. Manhattan distance to zero is 60.
// ContainsNaN is false. Zero forward is ForwardVector.
// Boundary/ownership: Winding and Remainder are writebacks. Queries do not
// mutate the receiver except through those out parameters.

namespace TS_FRotator_Queries_01
{
	bool Observe_IsNearlyZero_Nominal()
	{
		FRotator Zero = FRotator::ZeroRotator;
		FRotator Offset(10.0, 0.0, 0.0);
		return Zero.IsNearlyZero() && Zero.IsNearlyZero(KINDA_SMALL_NUMBER) && !Offset.IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		FRotator Zero;
		FRotator Offset(10.0, 0.0, 0.0);
		return Zero.IsZero() && !Offset.IsZero();
	}

	bool Observe_Equals_Nominal()
	{
		FRotator Left(10.0, 20.0, 30.0);
		FRotator Right(10.0, 20.0, 30.0);
		FRotator Different(10.0, 90.0, 30.0);
		return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
	}

	bool Observe_GetInverse_Nominal()
	{
		FRotator Yaw90(0.0, 90.0, 0.0);
		FRotator Inverse = Yaw90.GetInverse();
		FRotator RoundTrip = Inverse.GetInverse();
		return Inverse.Equals(FRotator(0.0, -90.0, 0.0)) && RoundTrip.Equals(Yaw90);
	}

	bool Observe_GetNormalized_Nominal()
	{
		FRotator Over(0.0, 270.0, 0.0);
		FRotator Normalized = Over.GetNormalized();
		return Normalized.Yaw == -90.0 && Over.Yaw == 270.0;
	}

	bool Observe_GetDenormalized_Nominal()
	{
		FRotator Signed(0.0, -90.0, 0.0);
		FRotator Denormalized = Signed.GetDenormalized();
		return Denormalized.Yaw == 270.0 && Signed.Yaw == -90.0;
	}

	bool Observe_GetWindingAndRemainder_Nominal()
	{
		FRotator Over(0.0, 370.0, 0.0);
		FRotator Winding;
		FRotator Remainder;
		Over.GetWindingAndRemainder(Winding, Remainder);
		return Winding.Yaw == 360.0 && Remainder.Yaw == 10.0 && Over.Yaw == 370.0;
	}

	bool Observe_GetManhattanDistance_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		float64 ToZero = Rotator.GetManhattanDistance(FRotator::ZeroRotator);
		float64 ToSelf = Rotator.GetManhattanDistance(Rotator);
		return ToZero == 60.0 && ToSelf == 0.0;
	}

	bool Observe_ContainsNaN_Nominal()
	{
		FRotator Finite(10.0, 20.0, 30.0);
		FRotator Zero;
		return !Finite.ContainsNaN() && !Zero.ContainsNaN();
	}

	bool Observe_GetForwardVector_Nominal()
	{
		FVector ZeroForward = FRotator::ZeroRotator.GetForwardVector();
		FVector Yaw90Forward = FRotator(0.0, 90.0, 0.0).GetForwardVector();
		return ZeroForward.Equals(FVector::ForwardVector) && Yaw90Forward.Equals(FVector::RightVector);
	}
}
/** @end */
