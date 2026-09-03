/**
 * Colors returned from functions: a constant, a literal and a computed mix. C++ executes
 * each entrypoint and compares the result with the native equivalent, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty default and
 * the independence of a copy.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.FunctionReturnValues
 * @Harness Function
 * @Tag Gameplay.FLinearColor.FunctionReturnValues
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive return-value oracles.
 * @Provenance C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionReturnValues
 * @Provenance Oracle: ReturnWhite == White; ReturnCustomColor Equals (0.3,0.6,0.9,1.0);
 * @Provenance ReturnComputedColor R>0.4 and B>0.4.
 * @Provenance Extra: default empty is not White; copy independence of computed mix. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Return a color constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return white
	 */
	UFUNCTION()
	FLinearColor ReturnWhite()
	{
		return FLinearColor::White;
	}

	/**
	 * Return a literal color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return FLinearColor(0.3, 0.6, 0.9, 1.0)
	 */
	UFUNCTION()
	FLinearColor ReturnCustomColor()
	{
		return FLinearColor(0.3, 0.6, 0.9, 1.0);
	}

	/**
	 * Return a color computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return the 50/50 mix of red and blue
	 */
	UFUNCTION()
	FLinearColor ReturnComputedColor()
	{
		FLinearColor a = FLinearColor::Red;
		FLinearColor b = FLinearColor::Blue;
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Observe that the constant return matches white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals white
	 */
	UFUNCTION()
	bool ReturnWhiteNominal()
	{
		return ReturnWhite() == FLinearColor::White;
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals (0.3, 0.6, 0.9, 1.0)
	 */
	UFUNCTION()
	bool ReturnCustomColorNominal()
	{
		return ReturnCustomColor().Equals(FLinearColor(0.3, 0.6, 0.9, 1.0), 0.001);
	}

	/**
	 * Observe that the computed return keeps both red and blue above 0.4.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when R and B are both greater than 0.4
	 */
	UFUNCTION()
	bool ReturnComputedColorNominal()
	{
		FLinearColor Result = ReturnComputedColor();

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that a default color is not white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs a default-constructed color
	 * @Return true when it differs from white
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnWhiteNotDefaultEmpty()
	{
		return FLinearColor() != FLinearColor::White;
	}

	/**
	 * Observe that mutating a copy leaves a fresh computed return untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs the computed color and a mutated copy of it
	 * @Return true when a fresh computed return still has R greater than 0.4
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnComputedColorCopyIndependence()
	{
		FLinearColor Result = ReturnComputedColor();
		Result.R = 0.0;
		return ReturnComputedColor().R > 0.4;
	}
}
