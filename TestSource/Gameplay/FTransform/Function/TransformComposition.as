/**
 * The FTransform composition operator *: two translations, a scale times a translation,
 * and a product of three transforms. C++ executes each entrypoint and compares the result
 * with the native equivalent, so those names are part of the contract and are kept
 * verbatim. The observers cover identity composition and the independence of a copy.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.Composition
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformComposition
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive composition * oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformComposition
 * @Provenance Oracle: T1*T2 native; scale*translation native; three-transform product native.
 * @Provenance Extra: Identity * Identity; copy independence of T1. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Compose two translation-only transforms.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return T1 * T2 for (100,0,0) and (0,200,0)
	 */
	UFUNCTION()
	FTransform ComposeTransforms()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 200, 0));
		return T1 * T2;
	}

	/**
	 * Compose a uniform scale with a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return T1 * T2 for scale (2,2,2) and translation (10,10,10)
	 */
	UFUNCTION()
	FTransform ComposeWithScale()
	{
		FTransform T1 = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
		FTransform T2 = FTransform(FVector(10, 10, 10));
		return T1 * T2;
	}

	/**
	 * Compose three translation-only transforms.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return T1 * T2 * T3
	 */
	UFUNCTION()
	FTransform ComposeThree()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 100, 0));
		FTransform T3 = FTransform(FVector(0, 0, 100));
		return T1 * T2 * T3;
	}

	/**
	 * Observe that two-transform composition matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return true when ComposeTransforms equals T1 * T2
	 */
	UFUNCTION()
	bool ComposeTransformsNominal()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 200, 0));
		return ComposeTransforms().Equals(T1 * T2, 0.001);
	}

	/**
	 * Observe that scale-times-translation matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return true when ComposeWithScale equals T1 * T2
	 */
	UFUNCTION()
	bool ComposeWithScaleNominal()
	{
		FTransform T1 = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
		FTransform T2 = FTransform(FVector(10, 10, 10));
		return ComposeWithScale().Equals(T1 * T2, 0.001);
	}

	/**
	 * Observe that the three-transform product matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs none
	 * @Return true when ComposeThree equals T1 * T2 * T3
	 */
	UFUNCTION()
	bool ComposeThreeNominal()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 100, 0));
		FTransform T3 = FTransform(FVector(0, 0, 100));
		return ComposeThree().Equals(T1 * T2 * T3, 0.001);
	}

	/**
	 * Observe that composing two identities stays at identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs two default/identity transforms
	 * @Return true when the product equals identity
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ComposeDefaultIdentity()
	{
		return (FTransform() * FTransform::Identity).Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that mutating the product leaves the factors untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Composition
	 * @Inputs T1, T2 and a mutated product
	 * @Return true when T1 still reads (100,0,0) and T2 still reads (0,200,0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ComposeTransformsCopyIndependence()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 200, 0));
		FTransform Product = T1 * T2;
		Product.SetLocation(FVector::ZeroVector);

		if (!T1.GetLocation().Equals(FVector(100, 0, 0), 0.001))
		{
			return false;
		}
		return T2.GetLocation().Equals(FVector(0, 200, 0), 0.001);
	}
}
