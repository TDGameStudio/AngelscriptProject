/**
 * Rotators returned from functions: a constant, a literal and a computed sum. C++
 * executes each entrypoint and compares the result with the native equivalent, so those
 * names are part of the contract and are kept verbatim. The observers cover the empty
 * default and the independence of a copy.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.FunctionReturnValues
 * @Harness Function
 * @Tag Math.FRotator.FunctionReturnValues
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive return-value oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionReturnValues
 * @Provenance Oracle: ReturnZeroRotator Zero; ReturnCustomRotator (45,90,135);
 * @Provenance ReturnComputedRotator (15,30,45).
 * @Provenance Extra: default empty is Zero; copy independence of computed sum. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Return a rotator constant.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return the zero rotator
	 */
	UFUNCTION()
	FRotator ReturnZeroRotator()
	{
		return FRotator::ZeroRotator;
	}

	/**
	 * Return a literal rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return FRotator(45, 90, 135)
	 */
	UFUNCTION()
	FRotator ReturnCustomRotator()
	{
		return FRotator(45, 90, 135);
	}

	/**
	 * Return a rotator computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return FRotator(15, 30, 45)
	 */
	UFUNCTION()
	FRotator ReturnComputedRotator()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(5, 10, 15);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the zero rotator
	 */
	UFUNCTION()
	bool ReturnZeroRotatorNominal()
	{
		return ReturnZeroRotator() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FRotator(45, 90, 135)
	 */
	UFUNCTION()
	bool ReturnCustomRotatorNominal()
	{
		return ReturnCustomRotator() == FRotator(45, 90, 135);
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool ReturnComputedRotatorNominal()
	{
		return ReturnComputedRotator() == FRotator(15, 30, 45);
	}

	/**
	 * Observe that an empty rotator equals the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs a default-constructed rotator
	 * @Return true when it equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnZeroRotatorDefaultEmpty()
	{
		return FRotator() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating a copy leaves a fresh computed return untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs a mutated copy of a computed return
	 * @Return true when a fresh computed return still reads (15, 30, 45)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnComputedRotatorCopyIndependence()
	{
		FRotator Result = ReturnComputedRotator();
		Result.Pitch = 0.0;
		return ReturnComputedRotator() == FRotator(15, 30, 45);
	}
}
