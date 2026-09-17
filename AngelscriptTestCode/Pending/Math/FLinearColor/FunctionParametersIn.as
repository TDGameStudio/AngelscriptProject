/**
 * @version v1
 * @summary A FLinearColor passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and.
 * @topic Math
 */
/**
 * @version root
 * @summary A FLinearColor passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Measure the luminance of a color passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs a color
	 * @Return the luminance of the color
	 * @Param c the color to measure
	 */
	UFUNCTION()
	float AcceptColorIn(FLinearColor&in c)
	{
		return c.GetLuminance();
	}

	/**
	 * Observe that white measures as a high luminance.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the luminance is greater than 0.9
	 */
	UFUNCTION()
	bool AcceptColorInWhite()
	{
		FLinearColor Input = FLinearColor::White;
		return AcceptColorIn(Input) > 0.9;
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs a default-constructed color
	 * @Return true when the luminance is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptColorInDefaultEmpty()
	{
		FLinearColor Empty = FLinearColor();
		return AcceptColorIn(Empty) == 0.0;
	}

	/**
	 * Observe that black measures zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs black
	 * @Return true when the luminance is 0
	 * @Boundary black
	 */
	UFUNCTION()
	bool AcceptColorInBlackBoundary()
	{
		FLinearColor Input = FLinearColor::Black;
		return AcceptColorIn(Input) == 0.0;
	}
}
/** @end */
