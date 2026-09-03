/**
 * The FTransform inverse paths: Inverse of a translation, InverseTransformPosition,
 * InverseTransformVector under scale, and a round-trip through TransformPosition. C++
 * executes each entrypoint and compares the result with the native equivalent, so those
 * names are part of the contract and are kept verbatim. The observers cover identity
 * inverse and the independence of the original point.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.Inverse
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformInverse
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive Inverse / InverseTransform oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInverse
 * @Provenance Oracle: Inverse of (100,200,300); InverseTransformPosition (110)->native;
 * @Provenance InverseTransformVector (20,0,0) under scale 2; InverseRoundTrip (10,20,30).
 * @Provenance Extra: Identity Inverse; copy independence of Original. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Invert a translation-only transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return Inverse of FTransform(FVector(100, 200, 300))
	 */
	UFUNCTION()
	FTransform GetInverse()
	{
		FTransform T = FTransform(FVector(100, 200, 300));
		return T.Inverse();
	}

	/**
	 * Inverse-transform a world point through a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return InverseTransformPosition of (110, 0, 0)
	 */
	UFUNCTION()
	FVector InverseTransformPosition()
	{
		FTransform T = FTransform(FVector(100, 0, 0));
		FVector WorldPoint = FVector(110, 0, 0);
		return T.InverseTransformPosition(WorldPoint);
	}

	/**
	 * Inverse-transform a world vector through a uniform scale of two.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return InverseTransformVector of (20, 0, 0)
	 */
	UFUNCTION()
	FVector InverseTransformVector()
	{
		FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
		FVector WorldVec = FVector(20, 0, 0);
		return T.InverseTransformVector(WorldVec);
	}

	/**
	 * Round-trip a local point through TransformPosition and InverseTransformPosition.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return the original local point (10, 20, 30)
	 */
	UFUNCTION()
	FVector InverseRoundTrip()
	{
		FTransform T = FTransform(FVector(100, 200, 300));
		FVector Original = FVector(10, 20, 30);
		FVector World = T.TransformPosition(Original);
		return T.InverseTransformPosition(World);
	}

	/**
	 * Observe that GetInverse matches the native inverse.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return true when GetInverse equals T.Inverse()
	 */
	UFUNCTION()
	bool GetInverseNominal()
	{
		FTransform T = FTransform(FVector(100, 200, 300));
		return GetInverse().Equals(T.Inverse(), 0.001);
	}

	/**
	 * Observe that InverseTransformPosition matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return true when the result equals the native InverseTransformPosition
	 */
	UFUNCTION()
	bool InverseTransformPositionNominal()
	{
		FTransform T = FTransform(FVector(100, 0, 0));
		return InverseTransformPosition().Equals(T.InverseTransformPosition(FVector(110, 0, 0)), 0.001);
	}

	/**
	 * Observe that InverseTransformVector matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return true when the result equals the native InverseTransformVector
	 */
	UFUNCTION()
	bool InverseTransformVectorNominal()
	{
		FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
		return InverseTransformVector().Equals(T.InverseTransformVector(FVector(20, 0, 0)), 0.001);
	}

	/**
	 * Observe that the round-trip recovers the original local point.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs none
	 * @Return true when the result equals (10, 20, 30)
	 */
	UFUNCTION()
	bool InverseRoundTripNominal()
	{
		return InverseRoundTrip().Equals(FVector(10, 20, 30), 0.01);
	}

	/**
	 * Observe that inverting a default transform stays at identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs a default-constructed transform
	 * @Return true when Inverse equals identity
	 * @Boundary default value
	 */
	UFUNCTION()
	bool GetInverseDefaultIdentity()
	{
		return FTransform().Inverse().Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that mutating the world point leaves the original local point untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Inverse
	 * @Inputs a local point transformed to world and then mutated
	 * @Return true when the original still reads (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool InverseRoundTripCopyIndependence()
	{
		FVector Original = FVector(10, 20, 30);
		FTransform T = FTransform(FVector(100, 200, 300));
		FVector World = T.TransformPosition(Original);
		World.X = 0.0;
		return Original.Equals(FVector(10, 20, 30));
	}
}
