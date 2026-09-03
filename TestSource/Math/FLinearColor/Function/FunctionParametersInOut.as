/**
 * A FLinearColor passed by mutable reference and scaled in place. C++ executes the
 * entrypoint and checks the value written back, so the name is part of the contract and
 * is kept verbatim. The observers cover a zero scale and the empty argument.
 *
 * @Theme Math.FLinearColor
 * @Subject FLinearColor.FunctionParametersInOut
 * @Harness Function
 * @Tag Math.FLinearColor.FunctionParametersInOut
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive &inout brighten oracle.
 * @Provenance C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersInOut
 * @Provenance Oracle: BrightenColor((0.5,0.5,0.5,1.0), 2.0) Equals (1,1,1,2).
 * @Provenance Extra: amount 0 yields zero RGB; default empty * 2. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Scale a color in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a color and a scale factor
	 * @Return the color scaled in place
	 * @Param c the color to scale
	 * @Param amount the factor to scale by
	 */
	UFUNCTION()
	void BrightenColor(FLinearColor&inout c, float amount)
	{
		c = c * amount;
	}

	/**
	 * Observe that the caller's color is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads (1, 1, 1, 2)
	 */
	UFUNCTION()
	bool BrightenColorNominal()
	{
		FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
		BrightenColor(Value, 2.0);
		return Value.Equals(FLinearColor(1.0, 1.0, 1.0, 2.0), 0.001);
	}

	/**
	 * Observe that a zero scale lands every component at zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a color scaled by 0
	 * @Return true when the value reads (0, 0, 0, 0)
	 * @Boundary zero amount
	 */
	UFUNCTION()
	bool BrightenColorZeroAmount()
	{
		FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
		BrightenColor(Value, 0.0);
		return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 0.0), 0.001);
	}

	/**
	 * Observe that scaling an empty color doubles only the default alpha.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a default-constructed color
	 * @Return true when the value reads (0, 0, 0, 2)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BrightenColorDefaultEmpty()
	{
		FLinearColor Value = FLinearColor();
		BrightenColor(Value, 2.0);
		return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
	}
}
