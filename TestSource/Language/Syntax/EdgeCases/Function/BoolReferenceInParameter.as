/**
 * A bool passed by const reference and read back. The observers confirm both
 * truth values survive the reference.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolReferenceInParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolReferenceInParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersIn
 * @Provenance sha256=4d90f53504f13be4e4f008f68f6bc7b0c90c5e890cbb99a8187dcd1332afc80e; lines 83-88.
 * @Provenance Oracle: PassThrough(true) is true. Extra: PassThrough(false) is false.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Reads a bool received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming bool reference
	 * @Return the referenced value
	 * @Param b the read-only reference
	 */
	bool PassThrough(const bool&in b)
	{
		return b;
	}

	/**
	 * Observe that true passes through the reference.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a true-valued local
	 * @Return true when the result is true
	 */
	UFUNCTION()
	bool BoolInNominal()
	{
		bool Value = true;
		return PassThrough(Value) == true;
	}

	/**
	 * Observe that false passes through the reference.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a false-valued local
	 * @Return true when the result is false
	 * @Boundary false input
	 */
	UFUNCTION()
	bool BoolInFalseBoundary()
	{
		bool Value = false;
		return PassThrough(Value) == false;
	}
}
