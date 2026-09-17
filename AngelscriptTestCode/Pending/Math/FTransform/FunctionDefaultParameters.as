/**
 * @version v1
 * @summary A defaulted transform parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary A defaulted transform parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
namespace FTransformTest
{
	/**
	 * Compose two transforms, where the second defaults to the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform and an optional second transform
	 * @Return the product of the two
	 * @Param a the first transform
	 * @Param b the second transform, defaulting to identity
	 */
	UFUNCTION()
	FTransform ComposeWithDefault(FTransform a, FTransform b = FTransform::Identity)
	{
		return a * b;
	}

	/**
	 * Compose a transform relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform
	 * @Return the transform composed with identity
	 * @Param a the transform to compose
	 */
	UFUNCTION()
	FTransform ComposeUsingDefault(FTransform a)
	{
		return ComposeWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the product equals A * B
	 */
	UFUNCTION()
	bool ComposeWithDefaultExplicit()
	{
		FTransform Arg1 = FTransform(FVector(100, 0, 0));
		FTransform Arg2 = FTransform(FVector(0, 100, 0));
		FTransform Expected = Arg1 * Arg2;
		return ComposeWithDefault(Arg1, Arg2).Equals(Expected, 0.01);
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the product equals A * Identity
	 */
	UFUNCTION()
	bool ComposeUsingDefaultNominal()
	{
		FTransform Arg1 = FTransform(FVector(100, 200, 300));
		FTransform Expected = Arg1 * FTransform::Identity;
		return ComposeUsingDefault(Arg1).Equals(Expected, 0.01);
	}

	/**
	 * Observe that composing an identity with the default stays at identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a default-constructed transform
	 * @Return true when the product is identity with a zero location
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ComposeUsingDefaultIdentityEmpty()
	{
		FTransform Empty = FTransform::Identity;

		if (!ComposeUsingDefault(Empty).Equals(FTransform::Identity, 0.01))
		{
			return false;
		}
		return ComposeUsingDefault(Empty).GetLocation().Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that mutating the returned product leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionDefaultParameters
	 * @Inputs a transform and the mutated product built from it
	 * @Return true when the argument still reads (100, 200, 300)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ComposeUsingDefaultCopyIndependence()
	{
		FTransform Arg1 = FTransform(FVector(100, 200, 300));
		FTransform Result = ComposeUsingDefault(Arg1);
		Result.SetLocation(FVector::ZeroVector);
		return Arg1.GetLocation().Equals(FVector(100, 200, 300), 0.01);
	}
}
/** @end */
