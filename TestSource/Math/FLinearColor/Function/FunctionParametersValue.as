/**
 * FLinearColors passed by value, where the callee receives its own copy. C++ executes
 * each entrypoint and checks the value it produces, so those names are part of the
 * contract and are kept verbatim. The observers cover the empty argument and the
 * independence of the caller's colors.
 *
 * @Theme Math.FLinearColor
 * @Subject FLinearColor.FunctionParametersValue
 * @Harness Function
 * @Tag Math.FLinearColor.FunctionParametersValue
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive value-parameter oracles.
 * @Provenance C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersValue
 * @Provenance Oracle: AcceptColor(0.2,0.3,0.4,0.5) Equals (0.4,0.6,0.8,1.0);
 * @Provenance BlendColors(Red, Blue) R>0.4 and B>0.4.
 * @Provenance Extra: AcceptColor default empty; BlendColors copy independence. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Double every component of a color passed by value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs a color
	 * @Return the color with every component doubled
	 * @Param c the color to scale
	 */
	UFUNCTION()
	FLinearColor AcceptColor(FLinearColor c)
	{
		return c * 2.0;
	}

	/**
	 * Blend two colors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs two colors
	 * @Return the 50/50 blend of the two
	 * @Param a the first color
	 * @Param b the second color
	 */
	UFUNCTION()
	FLinearColor BlendColors(FLinearColor a, FLinearColor b)
	{
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Observe that doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals (0.4, 0.6, 0.8, 1.0)
	 */
	UFUNCTION()
	bool AcceptColorNominal()
	{
		return AcceptColor(FLinearColor(0.2, 0.3, 0.4, 0.5)).Equals(FLinearColor(0.4, 0.6, 0.8, 1.0), 0.001);
	}

	/**
	 * Observe that blending red and blue keeps both channels above 0.4.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs none
	 * @Return true when R and B are both greater than 0.4
	 */
	UFUNCTION()
	bool BlendColorsNominal()
	{
		FLinearColor Result = BlendColors(FLinearColor::Red, FLinearColor::Blue);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that doubling an empty color doubles only the default alpha.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs a default-constructed color
	 * @Return true when the result equals (0, 0, 0, 2)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptColorDefaultEmpty()
	{
		return AcceptColor(FLinearColor()).Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
	}

	/**
	 * Observe that mutating the returned blend leaves both arguments alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs two colors and the mutated blend built from them
	 * @Return true when both arguments still read red and blue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendColorsCopyIndependence()
	{
		FLinearColor A = FLinearColor::Red;
		FLinearColor B = FLinearColor::Blue;
		FLinearColor Mid = BlendColors(A, B);
		Mid.R = 0.0;

		if (!A.Equals(FLinearColor::Red))
		{
			return false;
		}
		return B.Equals(FLinearColor::Blue);
	}
}
