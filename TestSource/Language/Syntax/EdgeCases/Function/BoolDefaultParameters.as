/**
 * Bool parameters with default arguments. The observers confirm both defaults are
 * used when omitted and that explicit arguments override them.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolDefaultParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolDefaultParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionDefaultParameters
 * @Provenance sha256=05e642a8f87e3019a0c9a32e05101c120063fad8231421f1e893818ab71f9280; lines 239-259.
 * @Provenance Oracle: CallDefaultTrue is true; CallDefaultFalse is false; EchoDefaultTrue(false)
 * @Provenance overrides the default. Extra: EchoDefaultFalse(true) overrides false.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Echoes a bool whose default is true.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an optional bool defaulting to true
	 * @Return the echoed value
	 * @Param b the optional argument
	 */
	bool EchoDefaultTrue(bool b = true)
	{
		return b;
	}

	/**
	 * Echoes a bool whose default is false.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an optional bool defaulting to false
	 * @Return the echoed value
	 * @Param b the optional argument
	 */
	bool EchoDefaultFalse(bool b = false)
	{
		return b;
	}

	/**
	 * Calls the true-defaulted helper without an argument.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return true, using the default
	 */
	bool CallDefaultTrue()
	{
		return EchoDefaultTrue();
	}

	/**
	 * Calls the false-defaulted helper without an argument.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return false, using the default
	 */
	bool CallDefaultFalse()
	{
		return EchoDefaultFalse();
	}

	/**
	 * Observe that both defaults apply when omitted.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both default-omitting calls
	 * @Return true when true and false defaults are echoed
	 */
	UFUNCTION()
	bool BoolDefaultsNominal()
	{
		if (CallDefaultTrue() != true)
		{
			return false;
		}

		return CallDefaultFalse() == false;
	}

	/**
	 * Observe that explicit arguments override both defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both helpers with opposite explicit arguments
	 * @Return true when both overrides take effect
	 * @Boundary explicit override
	 */
	UFUNCTION()
	bool BoolDefaultsOverrideBoundary()
	{
		if (EchoDefaultTrue(false) != false)
		{
			return false;
		}

		return EchoDefaultFalse(true) == true;
	}
}
