/**
 * FRotator::MakeFromEuler, exercised on a known Euler vector and on the zero vector. C++
 * executes the entrypoint and compares the result with the native equivalent, so the name
 * is part of the contract and is kept verbatim.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.StaticMethods
 * @Harness Function
 * @Tag Math.FRotator.RotatorStaticMethods
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive MakeFromEuler oracle.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorStaticMethods
 * @Provenance Oracle: MakeFromEuler(10,20,30) Equals native MakeFromEuler.
 * @Provenance Extra: MakeFromEuler ZeroVector is ZeroRotator; copy independence of euler. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Build a rotator from an Euler vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.StaticMethods
	 * @Inputs none
	 * @Return FRotator::MakeFromEuler(FVector(10, 20, 30))
	 */
	UFUNCTION()
	FRotator MakeFromEuler()
	{
		FVector euler = FVector(10, 20, 30);
		return FRotator::MakeFromEuler(euler);
	}

	/**
	 * Observe that MakeFromEuler matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.StaticMethods
	 * @Inputs none
	 * @Return true when the result equals the native MakeFromEuler
	 */
	UFUNCTION()
	bool MakeFromEulerNominal()
	{
		return MakeFromEuler().Equals(FRotator::MakeFromEuler(FVector(10, 20, 30)), 0.001);
	}

	/**
	 * Observe that MakeFromEuler of the zero vector is the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.StaticMethods
	 * @Inputs FVector::ZeroVector
	 * @Return true when the result equals ZeroRotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool MakeFromEulerDefaultZero()
	{
		return FRotator::MakeFromEuler(FVector::ZeroVector).Equals(FRotator::ZeroRotator, 0.001);
	}

	/**
	 * Observe that mutating the rotator leaves the Euler vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.StaticMethods
	 * @Inputs an Euler vector and a mutated rotator built from it
	 * @Return true when the Euler vector still reads (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MakeFromEulerCopyIndependence()
	{
		FVector Euler = FVector(10, 20, 30);
		FRotator Result = FRotator::MakeFromEuler(Euler);
		Result.Pitch = 0.0;
		return Euler.Equals(FVector(10, 20, 30));
	}
}
