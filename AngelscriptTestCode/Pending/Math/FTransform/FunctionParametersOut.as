/**
 * @version v1
 * @summary FTransforms written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary FTransforms written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
namespace FTransformTest
{
	/**
	 * Write a fixed transform into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FTransform(FVector(100, 200, 300))
	 * @Param t the transform to write into
	 */
	UFUNCTION()
	void WriteTransform(FTransform&out t)
	{
		t = FTransform(FVector(100, 200, 300));
	}

	/**
	 * Write two translations into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as (10, 0, 0), the second as (0, 20, 0)
	 * @Param a the first transform to write into
	 * @Param b the second transform to write into
	 */
	UFUNCTION()
	void WriteMultipleTransforms(FTransform&out a, FTransform&out b)
	{
		a = FTransform(FVector(10, 0, 0));
		b = FTransform(FVector(0, 20, 0));
	}

	/**
	 * Observe that the single out parameter receives the written translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value reads (100, 200, 300)
	 */
	UFUNCTION()
	bool WriteTransformNominal()
	{
		FTransform OutValue;
		WriteTransform(OutValue);
		return OutValue.GetLocation().Equals(FVector(100, 200, 300), 0.01);
	}

	/**
	 * Observe that both out parameters receive their own translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads (10, 0, 0) and the second (0, 20, 0)
	 */
	UFUNCTION()
	bool WriteMultipleTransformsNominal()
	{
		FTransform OutA;
		FTransform OutB;
		WriteMultipleTransforms(OutA, OutB);

		if (!OutA.GetLocation().Equals(FVector(10, 0, 0), 0.01))
		{
			return false;
		}
		return OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when the translation is the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteTransformDefaultEmpty()
	{
		FTransform OutValue;
		return OutValue.GetLocation().Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads (0, 20, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleTransformsCopyIndependence()
	{
		FTransform OutA;
		FTransform OutB;
		WriteMultipleTransforms(OutA, OutB);
		OutA.SetLocation(FVector::ZeroVector);
		return OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
	}
}
/** @end */
