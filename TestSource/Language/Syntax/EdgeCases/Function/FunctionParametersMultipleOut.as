/**
 * A function writing through two bool out parameters at once. The observers
 * confirm the writes land from both seed orientations.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionParametersMultipleOut
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FunctionParametersMultipleOut
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersMultipleOut
 * @Provenance sha256=28b9c3a745491621e9e4c8c783c5b60c45e8b1b96747888790ad8a717604fd81; lines 139-145.
 * @Provenance Oracle: SetPair writes First=true, Second=false. Extra: inverted seeds are
 * @Provenance overwritten (copy-independence of the out writes). DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Writes both values through a pair of out parameters.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two out parameters to write
	 * @Return nothing; First receives true and Second receives false
	 * @Param First the first out parameter
	 * @Param Second the second out parameter
	 */
	void SetPair(bool&out First, bool&out Second)
	{
		First = true;
		Second = false;
	}

	/**
	 * Observe the writes from inverted seeds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs seeds false/true written through SetPair
	 * @Return true when First reads true and Second reads false
	 */
	UFUNCTION()
	bool SetPairNominal()
	{
		bool First = false;
		bool Second = true;
		SetPair(First, Second);

		if (First != true)
		{
			return false;
		}

		return Second == false;
	}

	/**
	 * Observe that matching seeds are simply overwritten.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs seeds true/false written through SetPair
	 * @Return true when First reads true and Second reads false
	 * @Boundary matching seeds
	 */
	UFUNCTION()
	bool SetPairSeededBoundary()
	{
		bool First = true;
		bool Second = false;
		SetPair(First, Second);

		if (First != true)
		{
			return false;
		}

		return Second == false;
	}
}
