/**
 * FRotators written through out parameters, where the callee fills in the caller's
 * variable. C++ executes each entrypoint and checks the values written, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty value before
 * the write and the independence of two out values.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.FunctionParametersOut
 * @Harness Function
 * @Tag Math.FRotator.FunctionParametersOut
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive &out parameter oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersOut
 * @Provenance Oracle: WriteRotator (45,90,180); WriteMultipleRotators A Zero, B (10,20,30).
 * @Provenance Extra: default out before write is Zero. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Write a fixed rotator into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FRotator(45, 90, 180)
	 * @Param r the rotator to write into
	 */
	UFUNCTION()
	void WriteRotator(FRotator&out r)
	{
		r = FRotator(45, 90, 180);
	}

	/**
	 * Write the zero rotator and a known triple into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as the zero rotator, the second as FRotator(10, 20, 30)
	 * @Param a the first rotator to write into
	 * @Param b the second rotator to write into
	 */
	UFUNCTION()
	void WriteMultipleRotators(FRotator&out a, FRotator&out b)
	{
		a = FRotator::ZeroRotator;
		b = FRotator(10, 20, 30);
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FRotator(45, 90, 180)
	 */
	UFUNCTION()
	bool WriteRotatorNominal()
	{
		FRotator OutValue;
		WriteRotator(OutValue);
		return OutValue == FRotator(45, 90, 180);
	}

	/**
	 * Observe that both out parameters receive their own value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads the zero rotator and the second reads (10, 20, 30)
	 */
	UFUNCTION()
	bool WriteMultipleRotatorsNominal()
	{
		FRotator OutA;
		FRotator OutB;
		WriteMultipleRotators(OutA, OutB);

		if (!(OutA == FRotator::ZeroRotator))
		{
			return false;
		}
		return OutB == FRotator(10, 20, 30);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteRotatorDefaultEmptyBeforeWrite()
	{
		FRotator OutValue;
		return OutValue == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads FRotator(10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleRotatorsCopyIndependence()
	{
		FRotator OutA;
		FRotator OutB;
		WriteMultipleRotators(OutA, OutB);
		OutA.Pitch = 99.0;
		return OutB == FRotator(10, 20, 30);
	}
}
