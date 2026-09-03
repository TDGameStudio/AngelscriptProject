/**
 * A bool flipped in place through an inout parameter. The observers confirm both
 * flip directions.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolInOutParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolInOutParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersInOut
 * @Provenance sha256=4141d8f2adf3cf8f6345ef338649eec457d4e5f309432f7cce6a79e1be02cb98; lines 171-176.
 * @Provenance Oracle: Toggle(true) writes false. Extra: Toggle(false) writes true.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Flips a bool in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to flip
	 * @Return nothing; the caller's local is inverted
	 * @Param b the inout parameter
	 */
	void Toggle(bool&inout b)
	{
		b = !b;
	}

	/**
	 * Observe that true flips to false.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a true-valued local toggled in place
	 * @Return true when the local reads false
	 */
	UFUNCTION()
	bool BoolInOutNominal()
	{
		bool Value = true;
		Toggle(Value);
		return Value == false;
	}

	/**
	 * Observe that false flips to true.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a false-valued local toggled in place
	 * @Return true when the local reads true
	 * @Boundary false input
	 */
	UFUNCTION()
	bool BoolInOutFalseBoundary()
	{
		bool Value = false;
		Toggle(Value);
		return Value == true;
	}
}
