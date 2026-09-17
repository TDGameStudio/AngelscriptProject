/**
 * @version v1
 * @summary Vectors returned from functions: a constant, a literal and a computed sum. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Math
 */
/**
 * @version root
 * @summary Vectors returned from functions: a constant, a literal and a computed sum. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
namespace FVectorTest
{
	/**
	 * Return a vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return the forward vector
	 */
	UFUNCTION()
	FVector ReturnForwardVector()
	{
		return FVector::ForwardVector;
	}

	/**
	 * Return a literal vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector(5, 10, 15)
	 */
	UFUNCTION()
	FVector ReturnCustomVector()
	{
		return FVector(5, 10, 15);
	}

	/**
	 * Return a vector computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector(5, 7, 9)
	 */
	UFUNCTION()
	FVector ReturnComputedVector()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the forward vector
	 */
	UFUNCTION()
	bool ReturnForwardVectorNominal()
	{
		return ReturnForwardVector().Equals(FVector::ForwardVector);
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 10, 15)
	 */
	UFUNCTION()
	bool ReturnCustomVectorNominal()
	{
		return ReturnCustomVector().Equals(FVector(5, 10, 15));
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 7, 9)
	 */
	UFUNCTION()
	bool ReturnComputedVectorNominal()
	{
		return ReturnComputedVector().Equals(FVector(5, 7, 9));
	}

	/**
	 * Observe that an empty vector equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnCustomVectorDefaultEmpty()
	{
		FVector Empty = FVector();
		return Empty.Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating a copy leaves the returned vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs the returned vector and a mutated copy of it
	 * @Return true when the returned one still reads (5, 10, 15) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomVectorCopyIndependence()
	{
		FVector Original = ReturnCustomVector();
		FVector Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector(5, 10, 15)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
/** @end */
