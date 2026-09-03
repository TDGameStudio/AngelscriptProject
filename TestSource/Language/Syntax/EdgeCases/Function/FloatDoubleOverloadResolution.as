/**
 * Overload resolution between float and double signatures distinguished by their
 * second parameter. The observers confirm each signature routes correctly,
 * including the false-path and zero-bias boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatDoubleOverloadResolution
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatDoubleOverloadResolution
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionOverloading
 * @Provenance sha256=ace5b036f383a62c834cbb82125be0cc8cd883a11c734fe4b5aea7f4a46a92cc; lines 433-453.
 * @Provenance Oracle: ProcessFloat(4,true)=41; ProcessDouble(4,2)=42; ReturnFloatByPrecision(10,true)~=11;
 * @Provenance ReturnDoubleByPrecision(10,2)~=12. Extra: false float path returns -1. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The float-signature processor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a float and a path selector
	 * @Return the scaled value plus 1, or -1 when the path is off
	 * @Param X the float input
	 * @Param bUseFloatPath whether the float path runs
	 */
	int ProcessFloat(float X, bool bUseFloatPath)
	{
		return bUseFloatPath ? int(X * 10.0f) + 1 : -1;
	}

	/**
	 * The double-signature processor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a double and an int bias
	 * @Return the scaled value plus the bias
	 * @Param X the double input
	 * @Param Bias the additive bias
	 */
	int ProcessDouble(double X, int Bias)
	{
		return int(X * 10.0) + Bias;
	}

	/**
	 * The float-signature echo.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a float and a path selector
	 * @Return the input plus 1, or -1 when the path is off
	 * @Param X the float input
	 * @Param bUseFloatPath whether the float path runs
	 */
	float ReturnFloatByPrecision(float X, bool bUseFloatPath)
	{
		return bUseFloatPath ? X + 1.0f : -1.0f;
	}

	/**
	 * The double-signature echo.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a double and an int bias
	 * @Return the input plus the bias
	 * @Param X the double input
	 * @Param Bias the additive bias
	 */
	double ReturnDoubleByPrecision(double X, int Bias)
	{
		return X + double(Bias);
	}

	/**
	 * Observe that all four signatures route correctly.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four helpers at their nominal values
	 * @Return true when all four results match
	 */
	UFUNCTION()
	bool FloatDoubleOverloadNominal()
	{
		if (ProcessFloat(4.0f, true) != 41)
		{
			return false;
		}

		if (ProcessDouble(4.0, 2) != 42)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(ReturnFloatByPrecision(10.0f, true), 11.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(ReturnDoubleByPrecision(10.0, 2), 12.0, 0.001);
	}

	/**
	 * Observe the off-path boundary of the float signatures.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both float helpers with the path off
	 * @Return true when both return -1
	 * @Boundary false path
	 */
	UFUNCTION()
	bool FloatDoubleOverloadFalsePathBoundary()
	{
		if (ProcessFloat(4.0f, false) != -1)
		{
			return false;
		}

		return Math::IsNearlyEqual(ReturnFloatByPrecision(10.0f, false), -1.0, 0.001);
	}

	/**
	 * Observe the zero-bias boundary of the double signatures.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both double helpers with zero input and zero bias
	 * @Return true when both return zero
	 * @Boundary zero bias
	 */
	UFUNCTION()
	bool FloatDoubleOverloadZeroBias()
	{
		if (ProcessDouble(0.0, 0) != 0)
		{
			return false;
		}

		return Math::IsNearlyEqual(ReturnDoubleByPrecision(0.0, 0), 0.0, 0.001);
	}
}
