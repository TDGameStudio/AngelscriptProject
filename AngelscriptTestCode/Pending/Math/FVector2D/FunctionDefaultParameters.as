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
namespace FVector2DTest
{
	/**
	 * Add two vectors, where the second defaults to the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector and an optional second vector
	 * @Return the sum of the two
	 * @Param a the first vector
	 * @Param b the second vector, defaulting to the unit vector
	 */
	UFUNCTION()
	FVector2D AddWithDefault(FVector2D a, FVector2D b = FVector2D::UnitVector)
	{
		return a + b;
	}

	/**
	 * Add to a vector relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector
	 * @Return the vector plus the unit vector
	 * @Param a the vector to add to
	 */
	UFUNCTION()
	FVector2D AddUsingDefault(FVector2D a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector2D(15, 30)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FVector2D(10, 20), FVector2D(5, 10)).Equals(FVector2D(15, 30));
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector2D(11, 21)
	 */
	UFUNCTION()
	bool AddUsingDefaultNominal()
	{
		return AddUsingDefault(FVector2D(10, 20)).Equals(FVector2D(11, 21));
	}

	/**
	 * Observe that adding an empty vector to the default yields the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a default-constructed vector
	 * @Return true when the sum equals the unit vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddUsingDefaultEmptyZero()
	{
		return AddUsingDefault(FVector2D()).Equals(FVector2D::UnitVector);
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector and the mutated sum built from it
	 * @Return true when the argument still reads FVector2D(10, 20)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddUsingDefaultCopyIndependence()
	{
		FVector2D Arg1 = FVector2D(10, 20);
		FVector2D Result = AddUsingDefault(Arg1);
		Result.X = 0.0;
		return Arg1.Equals(FVector2D(10, 20));
	}
}
/** @end */
