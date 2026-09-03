/**
 * Float and double values squared in place through inout parameters. The
 * observers confirm the nominal squares, the zero boundary, and that a negative
 * input squares positive.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatInOutParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatInOutParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersInOut
 * @Provenance sha256=72928376ba3334b6ad42a3acccef7f749471e06aa345b220a62e02a01befdc2a; lines 245-255.
 * @Provenance Oracle: SquareFloat(5) -> 25; SquareDouble(10) -> 100. Extra: zero stays 0; -5 squares to 25.
 * @Provenance DefaultSafe. &inout mutates the caller's storage.
 */

namespace SyntaxTest
{
	/**
	 * Squares a float in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to square
	 * @Return nothing; the caller's local is squared
	 * @Param X the inout parameter
	 */
	void SquareFloat(float&inout X)
	{
		X = X * X;
	}

	/**
	 * Squares a double in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to square
	 * @Return nothing; the caller's local is squared
	 * @Param X the inout parameter
	 */
	void SquareDouble(double&inout X)
	{
		X = X * X;
	}

	/**
	 * Observe that both helpers square their inputs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a float 5 local and a double 10 local
	 * @Return true when the locals read 25 and 100
	 */
	UFUNCTION()
	bool FloatInOutNominal()
	{
		float F = 5.0f;
		double D = 10.0;
		SquareFloat(F);
		SquareDouble(D);

		if (!Math::IsNearlyEqual(F, 25.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(D, 100.0, 0.001);
	}

	/**
	 * Observe that zero stays zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs zero-valued locals squared in place
	 * @Return true when both locals still read zero
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool FloatInOutZeroDefault()
	{
		float F = 0.0f;
		double D = 0.0;
		SquareFloat(F);
		SquareDouble(D);

		if (!Math::IsNearlyEqual(F, 0.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(D, 0.0, 0.001);
	}

	/**
	 * Observe that a negative input squares positive.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a -5 float local squared in place
	 * @Return true when the local reads 25
	 * @Boundary negative input
	 */
	UFUNCTION()
	bool FloatInOutNegativeBoundary()
	{
		float F = -5.0f;
		SquareFloat(F);
		return Math::IsNearlyEqual(F, 25.0, 0.001);
	}
}
