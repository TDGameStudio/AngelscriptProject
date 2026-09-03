/**
 * Float and double parameters passed by value. Each helper adds its own constant
 * so the observers can verify the copy semantics and the zero and negative
 * boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatValueParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatValueParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersValue
 * @Provenance sha256=707311a71c95c293e638ce01ac45ad467a2bfc092a876995d414f1392b7285b6; lines 43-53.
 * @Provenance Oracle: AcceptFloat(10.5) ~= 12.0; AcceptDouble(20.5) ~= 23.0.
 * @Provenance Extra: zero input uses only the addend; negative input stays negative plus addend.
 * @Provenance DefaultSafe. Value parameters copy; callers keep their originals.
 */

namespace SyntaxTest
{
	/**
	 * Adds a constant to a float received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming float
	 * @Return the input plus 1.5
	 * @Param X the incoming float
	 */
	float AcceptFloat(float X)
	{
		return X + 1.5f;
	}

	/**
	 * Adds a constant to a double received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming double
	 * @Return the input plus 2.5
	 * @Param X the incoming double
	 */
	double AcceptDouble(double X)
	{
		return X + 2.5;
	}

	/**
	 * Observe that both helpers add their constants.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptFloat(10.5) and AcceptDouble(20.5)
	 * @Return true when the results are 12.0 and 23.0
	 */
	UFUNCTION()
	bool FloatValueNominal()
	{
		if (!Math::IsNearlyEqual(AcceptFloat(10.5f), 12.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AcceptDouble(20.5), 23.0, 0.001);
	}

	/**
	 * Observe that zero inputs yield just the addends.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptFloat(0.0) and AcceptDouble(0.0)
	 * @Return true when the results are 1.5 and 2.5
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool FloatValueZeroDefault()
	{
		if (!Math::IsNearlyEqual(AcceptFloat(0.0f), 1.5, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AcceptDouble(0.0), 2.5, 0.001);
	}

	/**
	 * Observe that negative inputs stay negative plus the addend.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptFloat(-1.5) and AcceptDouble(-2.5)
	 * @Return true when both results are zero
	 * @Boundary negative input
	 */
	UFUNCTION()
	bool FloatValueNegativeBoundary()
	{
		if (!Math::IsNearlyEqual(AcceptFloat(-1.5f), 0.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AcceptDouble(-2.5), 0.0, 0.001);
	}
}
