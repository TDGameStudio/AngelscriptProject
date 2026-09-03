/**
 * Float and double default arguments. The observers confirm the defaults apply
 * when omitted, that zero plus the default yields the default, and that an
 * explicit zero overrides.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatDefaultParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatDefaultParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionDefaultParameters
 * @Provenance sha256=5d8c3a3799ae1bbb9e33ea0457cb9a387828470384df95060a8a85710dcab5bd; lines 351-371.
 * @Provenance Oracle: AddFloatDefaultImplicit(10) ~= 11.5; AddFloatDefault(10,4) ~= 14.0;
 * @Provenance AddDoubleDefaultImplicit(20) ~= 22.5; AddDoubleDefault(20,5) ~= 25.0.
 * @Provenance Extra: zero + default uses only the f-suffix / double literal. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Adds a float with a defaulted addend.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required X and an optional Y defaulting to 1.5
	 * @Return the sum of both
	 * @Param X the required addend
	 * @Param Y the optional addend
	 */
	float AddFloatDefault(float X, float Y = 1.5f)
	{
		return X + Y;
	}

	/**
	 * Adds a double with a defaulted addend.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required X and an optional Y defaulting to 2.5
	 * @Return the sum of both
	 * @Param X the required addend
	 * @Param Y the optional addend
	 */
	double AddDoubleDefault(double X, double Y = 2.5)
	{
		return X + Y;
	}

	/**
	 * Calls the float helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required float
	 * @Return the input plus 1.5
	 * @Param X the required addend
	 */
	float AddFloatDefaultImplicit(float X)
	{
		return AddFloatDefault(X);
	}

	/**
	 * Calls the double helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required double
	 * @Return the input plus 2.5
	 * @Param X the required addend
	 */
	double AddDoubleDefaultImplicit(double X)
	{
		return AddDoubleDefault(X);
	}

	/**
	 * Observe that both defaults and explicit values work.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four helpers at their nominal values
	 * @Return true when all four results match
	 */
	UFUNCTION()
	bool FloatDefaultsNominal()
	{
		if (!Math::IsNearlyEqual(AddFloatDefaultImplicit(10.0f), 11.5, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(AddFloatDefault(10.0f, 4.0f), 14.0, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(AddDoubleDefaultImplicit(20.0), 22.5, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AddDoubleDefault(20.0, 5.0), 25.0, 0.001);
	}

	/**
	 * Observe that zero plus each default yields the default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs zero inputs through both default-omitting helpers
	 * @Return true when the results are 1.5 and 2.5
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool FloatDefaultsZeroPlusDefault()
	{
		if (!Math::IsNearlyEqual(AddFloatDefaultImplicit(0.0f), 1.5, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AddDoubleDefaultImplicit(0.0), 2.5, 0.001);
	}

	/**
	 * Observe that an explicit zero overrides the default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both helpers with an explicit zero addend
	 * @Return true when the results are the unchanged inputs
	 * @Boundary explicit override
	 */
	UFUNCTION()
	bool FloatDefaultsExplicitOverrideBoundary()
	{
		if (!Math::IsNearlyEqual(AddFloatDefault(10.0f, 0.0f), 10.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AddDoubleDefault(20.0, 0.0), 20.0, 0.001);
	}
}
