/**
 * FRotator local and global declarations plus confirmed methods: Normalize, GetInverse,
 * axis helpers, winding, Manhattan distance, right/up vectors, delta and relative
 * round-trips. The plain-class member path raises a null-pointer exception and observers
 * never call it. C++ executes each entrypoint, so those names are kept verbatim.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.DeclarationsAndConfirmedMethods
 * @Harness Function
 * @Tag Math.FRotator.RotatorDeclarationsAndConfirmedMethods
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive declaration and confirmed-method oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorDeclarationsAndConfirmedMethods
 * @Provenance Oracle: LocalDefault 0; scalar ctor 21; copy ctor 6; local const 60; global const 0;
 * @Provenance NormalizeMutates (0,90,0); Inverse Equals native GetInverse; AxisHelpers 360;
 * @Provenance WindingAndRemainder true; Manhattan 45; RightVector; UpVector; Delta/Relative true.
 * @Provenance PlainClassMemberValueRaisesBoundary remains the Null pointer access exception path.
 * @Provenance Extra: default GlobalConst 0; Manhattan of Zero is 0. DefaultSafe.
 * @Provenance throws at runtime; the observers never call PlainClassMemberValueRaisesBoundary
 */

const FRotator GlobalConstRotator = FRotator::ZeroRotator;

/**
 * A plain (non-UObject) holder whose member access is the runtime-exception boundary.
 */
class FPlainRotatorHolder
{
	FRotator Value;

	/**
	 * Construct the holder with Value (2, 4, 6).
	 *
	 * @Kind Action
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return Value set to (2, 4, 6)
	 */
	FPlainRotatorHolder()
	{
		Value = FRotator(2, 4, 6);
	}
}

namespace FRotatorTest
{
	/**
	 * Sum the components of a default local rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	float LocalDefaultIsZero()
	{
		FRotator r;
		return r.Pitch + r.Yaw + r.Roll;
	}

	/**
	 * Sum the components of a scalar-constructed rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 21
	 */
	UFUNCTION()
	float LocalScalarConstructorSum()
	{
		FRotator r = FRotator(7);
		return r.Pitch + r.Yaw + r.Roll;
	}

	/**
	 * Sum the components of a copy-constructed rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 6
	 */
	UFUNCTION()
	float LocalCopyConstructorSum()
	{
		FRotator Source = FRotator(1, 2, 3);
		FRotator Copy = FRotator(Source);
		return Copy.Pitch + Copy.Yaw + Copy.Roll;
	}

	/**
	 * Sum the components of a const local rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 60
	 */
	UFUNCTION()
	float LocalConstValue()
	{
		const FRotator r = FRotator(10, 20, 30);
		return r.Pitch + r.Yaw + r.Roll;
	}

	/**
	 * Sum the components of the file-scope constant rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	float GlobalConstValue()
	{
		return GlobalConstRotator.Pitch + GlobalConstRotator.Yaw + GlobalConstRotator.Roll;
	}

	/**
	 * Normalize a rotator in place.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return FRotator(0, 90, 0) after Normalize of (0, 450, 0)
	 */
	UFUNCTION()
	FRotator NormalizeMutates()
	{
		FRotator r = FRotator(0, 450, 0);
		r.Normalize();
		return r;
	}

	/**
	 * Invert a yaw-90 rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return GetInverse of FRotator(0, 90, 0)
	 */
	UFUNCTION()
	FRotator InverseRotator()
	{
		return FRotator(0, 90, 0).GetInverse();
	}

	/**
	 * Sum NormalizeAxis(450) and ClampAxis(-90).
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 360
	 */
	UFUNCTION()
	float AxisHelpers()
	{
		return FRotator::NormalizeAxis(450) + FRotator::ClampAxis(-90);
	}

	/**
	 * Split a wrapped yaw into winding and remainder.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when winding is (0, 360, 0) and remainder is (0, 90, 0)
	 */
	UFUNCTION()
	bool WindingAndRemainder()
	{
		FRotator Winding;
		FRotator Remainder;
		FRotator(0, 450, 0).GetWindingAndRemainder(Winding, Remainder);

		if (!Winding.Equals(FRotator(0, 360, 0), 0.001))
		{
			return false;
		}
		return Remainder.Equals(FRotator(0, 90, 0), 0.001);
	}

	/**
	 * Measure Manhattan distance between two rotators.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return 45
	 */
	UFUNCTION()
	float ManhattanDistance()
	{
		return FRotator(10, 20, 30).GetManhattanDistance(FRotator(5, 5, 5));
	}

	/**
	 * Read the right vector of a zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return FVector::RightVector
	 */
	UFUNCTION()
	FVector RightVector()
	{
		return FRotator(0, 0, 0).GetRightVector();
	}

	/**
	 * Read the up vector of a zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return FVector::UpVector
	 */
	UFUNCTION()
	FVector UpVector()
	{
		return FRotator(0, 0, 0).GetUpVector();
	}

	/**
	 * Round-trip a delta between origin and a yaw-90 target.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when ApplyDelta recovers the target
	 */
	UFUNCTION()
	bool DeltaRoundTrip()
	{
		FRotator Origin = FRotator::ZeroRotator;
		FRotator Target = FRotator(0, 90, 0);
		FRotator Delta = FRotator::GetDelta(Origin, Target);
		return FRotator::ApplyDelta(Origin, Delta).Equals(Target, 0.05);
	}

	/**
	 * Round-trip a relative rotator between parent and child.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when ApplyRelative recovers the child
	 */
	UFUNCTION()
	bool RelativeRoundTrip()
	{
		FRotator Parent = FRotator(0, 30, 0);
		FRotator Child = FRotator(0, 75, 0);
		FRotator Relative = FRotator::GetRelative(Parent, Child);
		return FRotator::ApplyRelative(Parent, Relative).Equals(Child, 0.05);
	}

	/**
	 * Trigger the plain-class member path. Observers never call this; C++ expects the exception.
	 *
	 * @Kind Action
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs a default FPlainRotatorHolder
	 * @Return raises Null pointer access
	 * @Boundary null holder member
	 */
	UFUNCTION()
	int PlainClassMemberValueRaisesBoundary()
	{
		FPlainRotatorHolder Holder;
		return Holder.Value.Pitch + Holder.Value.Yaw + Holder.Value.Roll;
	}

	/**
	 * Observe that a default local rotator sums to zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when LocalDefaultIsZero is 0
	 */
	UFUNCTION()
	bool LocalDefaultIsZeroHolds()
	{
		return LocalDefaultIsZero() == 0.0;
	}

	/**
	 * Observe that the scalar constructor sums to 21.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when LocalScalarConstructorSum is 21
	 */
	UFUNCTION()
	bool LocalScalarConstructorSumHolds()
	{
		return LocalScalarConstructorSum() == 21.0;
	}

	/**
	 * Observe that the copy constructor sums to 6.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when LocalCopyConstructorSum is 6
	 */
	UFUNCTION()
	bool LocalCopyConstructorSumHolds()
	{
		return LocalCopyConstructorSum() == 6.0;
	}

	/**
	 * Observe that the const local sums to 60.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when LocalConstValue is 60
	 */
	UFUNCTION()
	bool LocalConstValueHolds()
	{
		return LocalConstValue() == 60.0;
	}

	/**
	 * Observe that the global constant sums to 0.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when GlobalConstValue is 0
	 */
	UFUNCTION()
	bool GlobalConstValueHolds()
	{
		return GlobalConstValue() == 0.0;
	}

	/**
	 * Observe that Normalize mutates to (0, 90, 0).
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when NormalizeMutates equals (0, 90, 0)
	 */
	UFUNCTION()
	bool NormalizeMutatesNominal()
	{
		return NormalizeMutates().Equals(FRotator(0, 90, 0), 0.001);
	}

	/**
	 * Observe that GetInverse matches the native inverse.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when InverseRotator equals the native GetInverse
	 */
	UFUNCTION()
	bool InverseRotatorNominal()
	{
		return InverseRotator().Equals(FRotator(0, 90, 0).GetInverse(), 0.001);
	}

	/**
	 * Observe that the axis helpers sum to 360.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when AxisHelpers is 360
	 */
	UFUNCTION()
	bool AxisHelpersNominal()
	{
		return AxisHelpers() == 360.0;
	}

	/**
	 * Observe that winding and remainder split as expected.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when WindingAndRemainder is true
	 */
	UFUNCTION()
	bool WindingAndRemainderHolds()
	{
		return WindingAndRemainder() == true;
	}

	/**
	 * Observe that Manhattan distance is 45.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when ManhattanDistance is 45
	 */
	UFUNCTION()
	bool ManhattanDistanceNominal()
	{
		return ManhattanDistance() == 45.0;
	}

	/**
	 * Observe that GetRightVector is the right axis.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when RightVector equals FVector::RightVector
	 */
	UFUNCTION()
	bool RightVectorNominal()
	{
		return RightVector().Equals(FVector::RightVector, 0.001);
	}

	/**
	 * Observe that GetUpVector is the up axis.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when UpVector equals FVector::UpVector
	 */
	UFUNCTION()
	bool UpVectorNominal()
	{
		return UpVector().Equals(FVector::UpVector, 0.001);
	}

	/**
	 * Observe that the delta round-trip holds.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when DeltaRoundTrip is true
	 */
	UFUNCTION()
	bool DeltaRoundTripHolds()
	{
		return DeltaRoundTrip() == true;
	}

	/**
	 * Observe that the relative round-trip holds.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs none
	 * @Return true when RelativeRoundTrip is true
	 */
	UFUNCTION()
	bool RelativeRoundTripHolds()
	{
		return RelativeRoundTrip() == true;
	}

	/**
	 * Observe that Manhattan distance of two zeros is 0.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationsAndConfirmedMethods
	 * @Inputs two zero rotators
	 * @Return true when the distance is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ManhattanDistanceDefaultZero()
	{
		return FRotator::ZeroRotator.GetManhattanDistance(FRotator::ZeroRotator) == 0.0;
	}
}
