/**
 * The FTransform Equals comparisons: identity against identity, equal translations, and
 * differing translations. C++ executes each entrypoint and checks the value it produces,
 * so those names are part of the contract and are kept verbatim. The observers cover the
 * empty default and the identity boundary.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.Comparison
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformComparison
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive Equals oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformComparison
 * @Provenance Oracle: CompareIdentity true; CompareEqual true; CompareNotEqual false.
 * @Provenance Extra: default Identity equals; Identity vs location false. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Compare two identity transforms for equality.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool CompareIdentity()
	{
		FTransform A = FTransform::Identity;
		FTransform B = FTransform::Identity;
		return A.Equals(B);
	}

	/**
	 * Compare two transforms that share a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool CompareEqual()
	{
		FTransform A = FTransform(FVector(100, 200, 300));
		FTransform B = FTransform(FVector(100, 200, 300));
		return A.Equals(B);
	}

	/**
	 * Compare two transforms with different translations.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool CompareNotEqual()
	{
		FTransform A = FTransform(FVector(100, 200, 300));
		FTransform B = FTransform(FVector(400, 500, 600));
		return A.Equals(B);
	}

	/**
	 * Observe that two identity transforms compare equal.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return true when CompareIdentity is true
	 */
	UFUNCTION()
	bool CompareIdentityHolds()
	{
		return CompareIdentity() == true;
	}

	/**
	 * Observe that two matching translations compare equal.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return true when CompareEqual is true
	 */
	UFUNCTION()
	bool CompareEqualHolds()
	{
		return CompareEqual() == true;
	}

	/**
	 * Observe that two differing translations do not compare equal.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs none
	 * @Return true when CompareNotEqual is false
	 */
	UFUNCTION()
	bool CompareNotEqualHolds()
	{
		return CompareNotEqual() == false;
	}

	/**
	 * Observe that a default transform equals the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs a default-constructed transform
	 * @Return true when it equals the identity
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEqualsIdentity()
	{
		return FTransform().Equals(FTransform::Identity) == true;
	}

	/**
	 * Observe that a located transform is not the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Comparison
	 * @Inputs a location-only transform
	 * @Return true when Equals against identity is false
	 * @Boundary identity
	 */
	UFUNCTION()
	bool LocationIsNotIdentity()
	{
		return FTransform(FVector(100, 200, 300)).Equals(FTransform::Identity) == false;
	}
}
