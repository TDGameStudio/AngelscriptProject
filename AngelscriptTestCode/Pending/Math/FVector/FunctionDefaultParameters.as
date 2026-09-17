/**
 * @version v1
 * @summary A defaulted vector parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary A defaulted vector parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
namespace FVectorTest
{
	/**
	 * Add two vectors, where the second defaults to the one vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector and an optional second vector
	 * @Return the sum of the two
	 * @Param a the first vector
	 * @Param b the second vector, defaulting to the one vector
	 */
	UFUNCTION()
	FVector AddWithDefault(FVector a, FVector b = FVector::OneVector)
	{
		return a + b;
	}

	/**
	 * Add to a vector relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector
	 * @Return the vector plus the one vector
	 * @Param a the vector to add to
	 */
	UFUNCTION()
	FVector AddUsingDefault(FVector a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector(5, 7, 9)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FVector(1, 2, 3), FVector(4, 5, 6)).Equals(FVector(5, 7, 9));
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector(2, 3, 4)
	 */
	UFUNCTION()
	bool AddUsingDefaultNominal()
	{
		return AddUsingDefault(FVector(1, 2, 3)).Equals(FVector(2, 3, 4));
	}

	/**
	 * Observe that adding an empty vector to the default yields the one vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a default-constructed vector
	 * @Return true when the sum equals the one vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddUsingDefaultEmptyZero()
	{
		return AddUsingDefault(FVector()).Equals(FVector::OneVector);
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector and the mutated sum built from it
	 * @Return true when the argument still reads FVector(1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddUsingDefaultCopyIndependence()
	{
		FVector Arg1 = FVector(1, 2, 3);
		FVector Result = AddUsingDefault(Arg1);
		Result.X = 0.0;
		return Arg1.Equals(FVector(1, 2, 3));
	}
}
/** @end */
