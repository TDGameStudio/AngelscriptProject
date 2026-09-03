/**
 * Default-parameter edge cases: multiple defaults consumed from one and two
 * wrapper depths, a negative default, and the int boundary default. The observers
 * confirm the defaults apply and that explicit values override them.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionDefaultParameterEdges
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FunctionDefaultParameterEdges
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionDefaultParameterEdges
 * @Provenance sha256=80a21dd603da09ee085888d7d58e036908d68a3386d4356b9d2c7dba871a46fe; lines 957-992.
 * @Provenance Oracle: MultipleDefaultsUsingBoth(12)==42; MultipleDefaultsUsingFinal(12, 10)==42;
 * @Provenance NegativeDefaultUsingDefault()==-7; BoundaryDefaultUsingDefault()==2147483647.
 * @Provenance Extra: MultipleDefaults(0)==30 empty A; NegativeDefault(-1)==-1 explicit override.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Sums a required int with two defaulted addends.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required A and optional B and C defaulting to 10 and 20
	 * @Return the sum of all three
	 * @Param A the required addend
	 * @Param B the first optional addend
	 * @Param C the second optional addend
	 */
	int MultipleDefaults(int A, int B = 10, int C = 20)
	{
		return A + B + C;
	}

	/**
	 * Calls the helper relying on both defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required int
	 * @Return the input plus 30
	 * @Param A the required addend
	 */
	int MultipleDefaultsUsingBoth(int A)
	{
		return MultipleDefaults(A);
	}

	/**
	 * Calls the helper overriding one default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required int and an explicit B
	 * @Return the sum with B applied and C defaulted
	 * @Param A the required addend
	 * @Param B the explicit middle addend
	 */
	int MultipleDefaultsUsingFinal(int A, int B)
	{
		return MultipleDefaults(A, B);
	}

	/**
	 * Echoes a negative defaulted parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an optional int defaulting to -7
	 * @Return the echoed value
	 * @Param Value the optional parameter
	 */
	int NegativeDefault(int Value = -7)
	{
		return Value;
	}

	/**
	 * Calls the negative-default helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return -7
	 */
	int NegativeDefaultUsingDefault()
	{
		return NegativeDefault();
	}

	/**
	 * Echoes the int-boundary defaulted parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an optional int defaulting to 2147483647
	 * @Return the echoed value
	 * @Param Value the optional parameter
	 */
	int BoundaryDefault(int Value = 2147483647)
	{
		return Value;
	}

	/**
	 * Calls the boundary-default helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 2147483647
	 */
	int BoundaryDefaultUsingDefault()
	{
		return BoundaryDefault();
	}

	/**
	 * Observe that all four default paths match their oracles.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four wrapper helpers
	 * @Return true when all four results match
	 */
	UFUNCTION()
	bool FunctionDefaultParameterEdgesNominal()
	{
		if (MultipleDefaultsUsingBoth(12) != 42)
		{
			return false;
		}

		if (MultipleDefaultsUsingFinal(12, 10) != 42)
		{
			return false;
		}

		if (NegativeDefaultUsingDefault() != -7)
		{
			return false;
		}

		return BoundaryDefaultUsingDefault() == 2147483647;
	}

	/**
	 * Observe that a zero required addend yields just the defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs MultipleDefaultsUsingBoth(0)
	 * @Return 30
	 * @Boundary zero input
	 */
	UFUNCTION()
	int FunctionDefaultParameterEdgesEmptyA()
	{
		return MultipleDefaultsUsingBoth(0);
	}

	/**
	 * Observe that an explicit value overrides the negative default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs NegativeDefault(-1)
	 * @Return -1
	 * @Boundary explicit override
	 */
	UFUNCTION()
	int FunctionDefaultParameterEdgesExplicitNegative()
	{
		return NegativeDefault(-1);
	}
}
