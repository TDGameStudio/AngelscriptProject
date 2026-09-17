/**
 * @version v1
 * @summary A defaulted rotator parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary A defaulted rotator parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Add two rotators, where the second defaults to the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator and an optional second rotator
	 * @Return the sum of the two
	 * @Param a the first rotator
	 * @Param b the second rotator, defaulting to the zero rotator
	 */
	UFUNCTION()
	FRotator AddWithDefault(FRotator a, FRotator b = FRotator::ZeroRotator)
	{
		return a + b;
	}

	/**
	 * Add to a rotator relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator
	 * @Return the rotator plus the zero rotator
	 * @Param a the rotator to add to
	 */
	UFUNCTION()
	FRotator AddWithImplicitDefault(FRotator a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FRotator(10, 20, 30)
	 */
	UFUNCTION()
	bool AddWithImplicitDefaultNominal()
	{
		return AddWithImplicitDefault(FRotator(10, 20, 30)) == FRotator(10, 20, 30);
	}

	/**
	 * Observe that adding an empty rotator to the default stays at the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a default-constructed rotator
	 * @Return true when the sum equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddWithDefaultEmptyZero()
	{
		return AddWithDefault(FRotator()) == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator and the mutated sum built from it
	 * @Return true when the argument still reads FRotator(10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddWithImplicitDefaultCopyIndependence()
	{
		FRotator Input = FRotator(10, 20, 30);
		FRotator Result = AddWithImplicitDefault(Input);
		Result.Pitch = 0.0;
		return Input == FRotator(10, 20, 30);
	}
}
/** @end */
