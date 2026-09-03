/**
 * A bool written through an out parameter. The observers confirm the write lands
 * from both a false and an already-true starting value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolOutParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BoolOutParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersOut
 * @Provenance sha256=76748e52aacbee9119a288eda4b03fe1a03f20805cd9641e41517339cb1667a6; lines 111-116.
 * @Provenance Oracle: SetTrue writes true into a false local. Extra: already-true stays true.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Writes true through an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives true
	 * @Param b the out parameter
	 */
	void SetTrue(bool&out b)
	{
		b = true;
	}

	/**
	 * Observe that a false local becomes true.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a false-valued local written through &out
	 * @Return true when the local reads true
	 */
	UFUNCTION()
	bool BoolOutNominal()
	{
		bool OutValue = false;
		SetTrue(OutValue);
		return OutValue == true;
	}

	/**
	 * Observe that an already-true local stays true.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a true-valued local written through &out
	 * @Return true when the local still reads true
	 * @Boundary already-true input
	 */
	UFUNCTION()
	bool BoolOutAlreadyTrueBoundary()
	{
		bool OutValue = true;
		SetTrue(OutValue);
		return OutValue == true;
	}
}
