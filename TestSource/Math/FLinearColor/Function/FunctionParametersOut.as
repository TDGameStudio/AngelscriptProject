/**
 * FLinearColors written through out parameters, where the callee fills in the caller's
 * variable. C++ executes each entrypoint and checks the values written, so those names
 * are part of the contract and are kept verbatim. The observers cover the empty value
 * before the write and the independence of two out values.
 *
 * @Theme Math.FLinearColor
 * @Subject FLinearColor.FunctionParametersOut
 * @Harness Function
 * @Tag Math.FLinearColor.FunctionParametersOut
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive &out parameter oracles.
 * @Provenance C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersOut
 * @Provenance Oracle: WriteColor -> (0.25,0.5,0.75,1.0); WriteMultipleColors A Red, B Green.
 * @Provenance Extra: default out before write is (0,0,0,1). DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Write a fixed color into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with (0.25, 0.5, 0.75, 1.0)
	 * @Param c the color to write into
	 */
	UFUNCTION()
	void WriteColor(FLinearColor&out c)
	{
		c = FLinearColor(0.25, 0.5, 0.75, 1.0);
	}

	/**
	 * Write two named colors into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as red, the second as green
	 * @Param a the first color to write into
	 * @Param b the second color to write into
	 */
	UFUNCTION()
	void WriteMultipleColors(FLinearColor&out a, FLinearColor&out b)
	{
		a = FLinearColor::Red;
		b = FLinearColor::Green;
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals (0.25, 0.5, 0.75, 1.0)
	 */
	UFUNCTION()
	bool WriteColorNominal()
	{
		FLinearColor OutValue;
		WriteColor(OutValue);
		return OutValue.Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.001);
	}

	/**
	 * Observe that both out parameters receive their own color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads red and the second reads green
	 */
	UFUNCTION()
	bool WriteMultipleColorsNominal()
	{
		FLinearColor OutA;
		FLinearColor OutB;
		WriteMultipleColors(OutA, OutB);

		if (OutA != FLinearColor::Red)
		{
			return false;
		}
		return OutB == FLinearColor::Green;
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals (0, 0, 0, 1)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteColorDefaultEmptyBeforeWrite()
	{
		FLinearColor OutValue;
		return OutValue.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads green and the first keeps R 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleColorsCopyIndependence()
	{
		FLinearColor OutA;
		FLinearColor OutB;
		WriteMultipleColors(OutA, OutB);
		OutA.G = 1.0;

		if (OutB != FLinearColor::Green)
		{
			return false;
		}
		return OutA.R == 1.0;
	}
}
