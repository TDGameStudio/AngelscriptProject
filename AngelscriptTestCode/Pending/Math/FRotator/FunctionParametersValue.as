/**
 * @version v1
 * @summary FRotators passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Math
 */
/**
 * @version root
 * @summary FRotators passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Double every component of a rotator passed by value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs a rotator
	 * @Return the rotator with every component doubled
	 * @Param r the rotator to scale
	 */
	UFUNCTION()
	FRotator AcceptRotator(FRotator r)
	{
		return r * 2.0;
	}

	/**
	 * Add two rotators passed by value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs two rotators
	 * @Return the sum of the two
	 * @Param a the first rotator
	 * @Param b the second rotator
	 */
	UFUNCTION()
	FRotator AcceptTwoRotators(FRotator a, FRotator b)
	{
		return a + b;
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FRotator(20, 40, 60)
	 */
	UFUNCTION()
	bool AcceptRotatorNominal()
	{
		return AcceptRotator(FRotator(10, 20, 30)) == FRotator(20, 40, 60);
	}

	/**
	 * Observe that the sum of two value parameters matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool AcceptTwoRotatorsNominal()
	{
		return AcceptTwoRotators(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
	}

	/**
	 * Observe that doubling an empty rotator stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs a default-constructed rotator
	 * @Return true when the result equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptRotatorDefaultEmpty()
	{
		return AcceptRotator(FRotator()) == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating the returned sum leaves both of the caller's arguments alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs two rotators and the mutated sum built from them
	 * @Return true when both arguments still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTwoRotatorsCopyIndependence()
	{
		FRotator A = FRotator(10, 20, 30);
		FRotator B = FRotator(5, 10, 15);
		FRotator Sum = AcceptTwoRotators(A, B);
		Sum.Pitch = 0.0;

		if (!(A == FRotator(10, 20, 30)))
		{
			return false;
		}
		return B == FRotator(5, 10, 15);
	}
}
/** @end */
