/**
 * An f-string that interpolates an arithmetic expression rather than a bare
 * variable. The expression is evaluated once during the rewrite.
 *
 * @Theme Language.Literals
 * @Subject Literals.FStringInterpolatesExpression
 * @Harness Function
 * @Tag Language.Literals.FStringInterpolatesExpression
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 6 AssertCompiles.
 * @Provenance sha256=9accba47d80eab4c94f9995f9ebeb47e592cfa56bcce3f69aa4d332029cfd116; lines 95-97.
 * @Provenance Oracle: f"Result: {5 * 2 + 1}" == "Result: 11".
 * @Provenance Extra: X = 0 yields "Result: 1"; mutating X after interpolation leaves S unchanged.
 * @Provenance DefaultSafe.
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
