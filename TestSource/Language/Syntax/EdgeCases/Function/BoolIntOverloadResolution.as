/**
 * Overload resolution between a bool and an int parameter of the same name. The
 * observers confirm each argument type picks its own overload, including the
 * false and zero boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolIntOverloadResolution
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolIntOverloadResolution
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionOverloading
 * @Provenance sha256=1a4f3aa7214fe832b60afad1b28298c2bc1795c78be80757b3b10e764ce8da37; lines 298-318.
 * @Provenance Oracle: CallBoolOverload == 10; CallIntOverload == 105. Extra: Pick(false)
 * @Provenance is 20; Pick(0) is 100. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The bool overload of Pick.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a bool argument
	 * @Return 10 when true, 20 when false
	 * @Param b the bool discriminator
	 */
	int Pick(bool b)
	{
		return b ? 10 : 20;
	}

	/**
	 * The int overload of Pick.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int argument
	 * @Return the input plus 100
	 * @Param Value the int addend
	 */
	int Pick(int Value)
	{
		return Value + 100;
	}

	/**
	 * Calls the bool overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int CallBoolOverload()
	{
		return Pick(true);
	}

	/**
	 * Calls the int overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 105
	 */
	int CallIntOverload()
	{
		return Pick(5);
	}

	/**
	 * Observe that each call picks its own overload.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both wrapper calls
	 * @Return true when the results are 10 and 105
	 */
	UFUNCTION()
	bool BoolIntOverloadNominal()
	{
		if (CallBoolOverload() != 10)
		{
			return false;
		}

		return CallIntOverload() == 105;
	}

	/**
	 * Observe the false and zero boundaries of both overloads.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Pick(false) and Pick(0)
	 * @Return true when the results are 20 and 100
	 * @Boundary false and zero inputs
	 */
	UFUNCTION()
	bool BoolIntOverloadFalseAndZeroBoundary()
	{
		if (Pick(false) != 20)
		{
			return false;
		}

		return Pick(0) == 100;
	}
}
