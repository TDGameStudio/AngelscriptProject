/**
 * The FRotator Normalize, Clamp, IsZero and IsNearlyZero paths. C++ executes each
 * entrypoint and checks the value it produces, so those names are part of the contract
 * and are kept verbatim.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.NormalizationMethods
 * @Harness Function
 * @Tag Math.FRotator.RotatorNormalizationMethods
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive Normalize / Clamp / IsZero oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorNormalizationMethods
 * @Provenance Oracle: GetNormalized (400,720,-400) Equals (40,0,-40); Clamp Equals native Clamp;
 * @Provenance IsZero true; IsNearlyZero true.
 * @Provenance Extra: default IsZero; (10,20,30) IsZero false. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Normalize a rotator whose components wrap past 360.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return GetNormalized of (400, 720, -400)
	 */
	UFUNCTION()
	FRotator NormalizeRotator()
	{
		FRotator r = FRotator(400, 720, -400);
		return r.GetNormalized();
	}

	/**
	 * Clamp a rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return Clamp of (100, 200, 100)
	 */
	UFUNCTION()
	FRotator ClampRotator()
	{
		FRotator r = FRotator(100, 200, 100);
		return r.Clamp();
	}

	/**
	 * Ask whether the zero rotator is zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool IsZero()
	{
		FRotator r = FRotator::ZeroRotator;
		return r.IsZero();
	}

	/**
	 * Ask whether a tiny rotator is nearly zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool IsNearlyZero()
	{
		FRotator r = FRotator(0.000001, 0.000001, 0.000001);
		return r.IsNearlyZero();
	}

	/**
	 * Observe that GetNormalized wraps to (40, 0, -40).
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true when NormalizeRotator equals (40, 0, -40)
	 */
	UFUNCTION()
	bool NormalizeRotatorNominal()
	{
		return NormalizeRotator().Equals(FRotator(40, 0, -40), 0.001);
	}

	/**
	 * Observe that Clamp matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true when ClampRotator equals the native Clamp
	 */
	UFUNCTION()
	bool ClampRotatorNominal()
	{
		return ClampRotator().Equals(FRotator(100, 200, 100).Clamp(), 0.001);
	}

	/**
	 * Observe that IsZero is true for the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true when IsZero is true
	 */
	UFUNCTION()
	bool IsZeroHolds()
	{
		return IsZero() == true;
	}

	/**
	 * Observe that IsNearlyZero is true for a tiny rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs none
	 * @Return true when IsNearlyZero is true
	 */
	UFUNCTION()
	bool IsNearlyZeroHolds()
	{
		return IsNearlyZero() == true;
	}

	/**
	 * Observe that a default rotator is zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs a default-constructed rotator
	 * @Return true when IsZero is true
	 * @Boundary default value
	 */
	UFUNCTION()
	bool IsZeroDefaultEmpty()
	{
		return FRotator().IsZero() == true;
	}

	/**
	 * Observe that a non-zero rotator is not zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.NormalizationMethods
	 * @Inputs FRotator(10, 20, 30)
	 * @Return true when IsZero is false
	 * @Boundary non-zero
	 */
	UFUNCTION()
	bool IsZeroNonZeroBoundary()
	{
		return FRotator(10, 20, 30).IsZero() == false;
	}
}
