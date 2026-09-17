/**
 * @version v1
 * @summary A FVector2D passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is.
 * @topic Math
 */
/**
 * @version root
 * @summary A FVector2D passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Measure the length of a vector passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a vector
	 * @Return the length of the vector
	 * @Param v the vector to measure
	 */
	UFUNCTION()
	float AcceptVectorIn(FVector2D&in v)
	{
		return v.Size();
	}

	/**
	 * Observe that the measured length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the length is 5
	 */
	UFUNCTION()
	bool AcceptVectorInNominal()
	{
		FVector2D Input = FVector2D(3, 4);
		return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a default-constructed vector
	 * @Return true when the length is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorInDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a vector read through the reference
	 * @Return true when the argument still reads FVector2D(3, 4) and the size is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorInCopyIndependence()
	{
		FVector2D Input = FVector2D(3, 4);
		float Size = AcceptVectorIn(Input);

		if (!Input.Equals(FVector2D(3, 4)))
		{
			return false;
		}
		return Math::IsNearlyEqual(Size, 5.0, 0.001);
	}
}
/** @end */
