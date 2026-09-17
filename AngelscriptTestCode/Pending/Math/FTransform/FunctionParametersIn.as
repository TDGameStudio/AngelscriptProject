/**
 * @version v1
 * @summary A FTransform passed by read-only reference, where the callee reads the translation without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is kept.
 * @topic Math
 */
/**
 * @version root
 * @summary A FTransform passed by read-only reference, where the callee reads the translation without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is kept.
 * @topic Baseline
 */
namespace FTransformTest
{
	/**
	 * Read the translation of a transform passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a transform
	 * @Return the translation of the transform
	 * @Param t the transform to read
	 */
	UFUNCTION()
	FVector AcceptTransformIn(FTransform&in t)
	{
		return t.GetLocation();
	}

	/**
	 * Observe that the measured translation matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the translation is (50, 100, 150)
	 */
	UFUNCTION()
	bool AcceptTransformInNominal()
	{
		FTransform Input = FTransform(FVector(50, 100, 150));
		return AcceptTransformIn(Input).Equals(FVector(50, 100, 150), 0.01);
	}

	/**
	 * Observe that an empty argument reads as the origin.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a default-constructed transform
	 * @Return true when the translation is the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptTransformInDefaultEmpty()
	{
		FTransform Empty = FTransform();
		return AcceptTransformIn(Empty).Equals(FVector::ZeroVector, 0.01);
	}

	/**
	 * Observe that reading through the reference leaves the caller's transform alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersIn
	 * @Inputs a transform read through the reference
	 * @Return true when the argument still reads (50, 100, 150)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTransformInCopyIndependence()
	{
		FTransform Input = FTransform(FVector(50, 100, 150));
		FVector Result = AcceptTransformIn(Input);
		Result.X = 0.0;
		return Input.GetLocation().Equals(FVector(50, 100, 150), 0.01);
	}
}
/** @end */
