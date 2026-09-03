/**
 * The FTransform TransformPosition and TransformVector paths: translation of a point,
 * scaled vector transform, scaled position transform, and a vector that ignores
 * translation. C++ executes each entrypoint and compares the result with the native
 * equivalent, so those names are part of the contract and are kept verbatim. The
 * observers cover identity of the origin and the independence of the input point.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.PositionAndVector
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformPositionAndVector
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive TransformPosition / TransformVector oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformPositionAndVector
 * @Provenance Oracle: native TransformPosition (10,0,0) under (100,0,0);
 * @Provenance TransformVector of (10,0,0) under scale 2;
 * @Provenance TransformPosition with scale (10,20,30)->native; TransformVector ignores translation.
 * @Provenance Extra: Identity TransformPosition of Zero; copy independence of Point. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Transform a local point through a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return TransformPosition of (10, 0, 0) under (100, 0, 0)
	 */
	UFUNCTION()
	FVector TransformPosition()
	{
		FTransform T = FTransform(FVector(100, 0, 0));
		FVector Point = FVector(10, 0, 0);
		return T.TransformPosition(Point);
	}

	/**
	 * Transform a local vector through a uniform scale of two.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return TransformVector of (10, 0, 0) under scale 2
	 */
	UFUNCTION()
	FVector TransformVector()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(2, 2, 2));
		FVector Vec = FVector(10, 0, 0);
		return T.TransformVector(Vec);
	}

	/**
	 * Transform a local point through translation and uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return TransformPosition of (10, 20, 30) under (50, 50, 50) scale 2
	 */
	UFUNCTION()
	FVector TransformPositionWithScale()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(50, 50, 50), FVector(2, 2, 2));
		FVector Point = FVector(10, 20, 30);
		return T.TransformPosition(Point);
	}

	/**
	 * Transform a local vector through a large translation, which vectors ignore.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return TransformVector of (1, 0, 0) under translation (1000, 1000, 1000)
	 */
	UFUNCTION()
	FVector TransformVectorNoTranslation()
	{
		FTransform T = FTransform(FVector(1000, 1000, 1000));
		FVector Vec = FVector(1, 0, 0);
		return T.TransformVector(Vec);
	}

	/**
	 * Observe that TransformPosition matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return true when the result equals the native TransformPosition
	 */
	UFUNCTION()
	bool TransformPositionNominal()
	{
		FTransform T = FTransform(FVector(100, 0, 0));
		return TransformPosition().Equals(T.TransformPosition(FVector(10, 0, 0)), 0.001);
	}

	/**
	 * Observe that TransformVector matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return true when the result equals the native TransformVector
	 */
	UFUNCTION()
	bool TransformVectorNominal()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(2, 2, 2));
		return TransformVector().Equals(T.TransformVector(FVector(10, 0, 0)), 0.001);
	}

	/**
	 * Observe that scaled TransformPosition matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return true when the result equals the native TransformPosition
	 */
	UFUNCTION()
	bool TransformPositionWithScaleNominal()
	{
		FTransform T = FTransform(FQuat::Identity, FVector(50, 50, 50), FVector(2, 2, 2));
		return TransformPositionWithScale().Equals(T.TransformPosition(FVector(10, 20, 30)), 0.001);
	}

	/**
	 * Observe that TransformVector ignores translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs none
	 * @Return true when the result equals the native TransformVector
	 */
	UFUNCTION()
	bool TransformVectorNoTranslationNominal()
	{
		FTransform T = FTransform(FVector(1000, 1000, 1000));
		return TransformVectorNoTranslation().Equals(T.TransformVector(FVector(1, 0, 0)), 0.001);
	}

	/**
	 * Observe that identity TransformPosition of the origin stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs a default-constructed transform
	 * @Return true when TransformPosition of ZeroVector is ZeroVector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool TransformPositionDefaultIdentity()
	{
		return FTransform().TransformPosition(FVector::ZeroVector).Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that mutating the world point leaves the original local point untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.PositionAndVector
	 * @Inputs a local point transformed to world and then mutated
	 * @Return true when the original still reads (10, 0, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TransformPositionCopyIndependence()
	{
		FVector Point = FVector(10, 0, 0);
		FTransform T = FTransform(FVector(100, 0, 0));
		FVector World = T.TransformPosition(Point);
		World.X = 0.0;
		return Point.Equals(FVector(10, 0, 0));
	}
}
