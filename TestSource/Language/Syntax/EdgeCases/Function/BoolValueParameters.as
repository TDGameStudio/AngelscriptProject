/**
 * A bool passed by value and negated. The observers confirm both directions of
 * the negation.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolValueParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolValueParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersValue
 * @Provenance sha256=5ad1d5d67ce622408ded3b625c2614b743f5b6f8d3f64af8906bf51ecffe98b6; lines 56-61.
 * @Provenance Oracle: Negate(true) is false. Extra: Negate(false) is true. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Negates a bool received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the value to negate
	 * @Return the inverted value
	 * @Param b the incoming bool
	 */
	bool Negate(bool b)
	{
		return !b;
	}

	/**
	 * Observe that true negates to false.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Negate(true)
	 * @Return true when the result is false
	 */
	UFUNCTION()
	bool BoolValueNegateTrue()
	{
		return Negate(true) == false;
	}

	/**
	 * Observe that false negates to true.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Negate(false)
	 * @Return true when the result is true
	 * @Boundary false input
	 */
	UFUNCTION()
	bool BoolValueNegateFalseBoundary()
	{
		return Negate(false) == true;
	}
}
