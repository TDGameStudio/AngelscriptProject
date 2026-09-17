/**
 * @version v1
 * @summary An f-string that interpolates an arithmetic expression rather than a bare variable. The expression is evaluated once during the rewrite.
 * @topic Language
 */
/**
 * @version root
 * @summary An f-string that interpolates an arithmetic expression rather than a bare variable. The expression is evaluated once during the rewrite.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Observe that an arithmetic expression interpolates and evaluates.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 5 interpolated as f"Result: {X * 2 + 1}"
	 * @Return true when the result is "Result: 11"
	 */
	UFUNCTION()
	bool FStringExpressionNominal()
	{
		int X = 5;
		FString S = f"Result: {X * 2 + 1}";
		return S == "Result: 11";
	}

	/**
	 * Observe the zero boundary of expression interpolation.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 0 interpolated as f"Result: {X * 2 + 1}"
	 * @Return true when the result is "Result: 1"
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool FStringExpressionZeroBoundary()
	{
		int X = 0;
		FString S = f"Result: {X * 2 + 1}";
		return S == "Result: 1";
	}

	/**
	 * Observe that mutating the operand does not rewrite the string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 5 interpolated, then X set to 0
	 * @Return true when the string keeps "Result: 11"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FStringExpressionCopyIndependence()
	{
		int X = 5;
		FString S = f"Result: {X * 2 + 1}";
		X = 0;
		return S == "Result: 11";
	}
}
/** @end */
