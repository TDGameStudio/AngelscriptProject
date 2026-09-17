/**
 * @version v1
 * @summary Transforms returned from functions: the identity constant, a literal translation, a computed product and an inverse. C++ executes each entrypoint and compares the result with the native equivalent, so those names are.
 * @topic Math
 */
/**
 * @version root
 * @summary Transforms returned from functions: the identity constant, a literal translation, a computed product and an inverse. C++ executes each entrypoint and compares the result with the native equivalent, so those names are.
 * @topic Baseline
 */
namespace FTransformTest
{
	/**
	 * Return the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return FTransform::Identity
	 */
	UFUNCTION()
	FTransform ReturnIdentity()
	{
		return FTransform::Identity;
	}

	/**
	 * Return a literal translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return FTransform(FVector(50, 100, 150))
	 */
	UFUNCTION()
	FTransform ReturnCustomTransform()
	{
		return FTransform(FVector(50, 100, 150));
	}

	/**
	 * Return a product of two translations.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return A * B for (100, 0, 0) and (0, 100, 0)
	 */
	UFUNCTION()
	FTransform ReturnComputedTransform()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(0, 100, 0));
		return A * B;
	}

	/**
	 * Return the inverse of a known translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return the inverse of FTransform(FVector(10, 20, 30))
	 */
	UFUNCTION()
	FTransform ReturnInverse()
	{
		FTransform T = FTransform(FVector(10, 20, 30));
		return T.Inverse();
	}

	/**
	 * Observe that the identity return matches the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals identity
	 */
	UFUNCTION()
	bool ReturnIdentityNominal()
	{
		return ReturnIdentity().Equals(FTransform::Identity, 0.01);
	}

	/**
	 * Observe that the literal return keeps its translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the location is (50, 100, 150)
	 */
	UFUNCTION()
	bool ReturnCustomTransformNominal()
	{
		return ReturnCustomTransform().GetLocation().Equals(FVector(50, 100, 150), 0.01);
	}

	/**
	 * Observe that the computed return matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals A * B
	 */
	UFUNCTION()
	bool ReturnComputedTransformNominal()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(0, 100, 0));
		FTransform Expected = A * B;
		return ReturnComputedTransform().Equals(Expected, 0.01);
	}

	/**
	 * Observe that the inverse return matches the native inverse.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals Inverse of (10, 20, 30)
	 */
	UFUNCTION()
	bool ReturnInverseNominal()
	{
		FTransform T = FTransform(FVector(10, 20, 30));
		FTransform Expected = T.Inverse();
		return ReturnInverse().Equals(Expected, 0.01);
	}

	/**
	 * Observe that a default transform equals the identity return.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs a default-constructed transform
	 * @Return true when it equals identity and the identity return
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnIdentityDefaultEmpty()
	{
		FTransform Empty = FTransform();

		if (!Empty.Equals(FTransform::Identity, 0.01))
		{
			return false;
		}
		return ReturnIdentity().Equals(Empty, 0.01);
	}

	/**
	 * Observe that mutating a copy leaves the returned transform untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionReturnValues
	 * @Inputs the returned transform and a mutated copy of it
	 * @Return true when the original still reads (50, 100, 150) and the copy is zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomTransformCopyIndependence()
	{
		FTransform Original = ReturnCustomTransform();
		FTransform Copy = Original;
		Copy.SetLocation(FVector::ZeroVector);

		if (!Original.GetLocation().Equals(FVector(50, 100, 150), 0.01))
		{
			return false;
		}
		return Copy.GetLocation().Equals(FVector::ZeroVector, 0.01);
	}
}
/** @end */
