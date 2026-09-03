/**
 * A function declared to return a bool delivers either flag, and the caller
 * receives the actual flag rather than a default. An uninitialised bool holds
 * false, so a false return is indistinguishable from an unset one by value
 * alone; the two returners staying distinct is what shows each is delivering
 * its own flag.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FunctionReturnBoolValues
 * @Harness Function
 * @Tag Language.ControlFlow.FunctionReturnBoolValues
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionReturnValues
 * @Provenance sha256=8c1bda041340a39e21ca14e985743c8aaee9f203da601d3be3a6c733f1fcf57e; lines 199-209.
 * @Provenance Oracle: ReturnTrue is true; ReturnFalse is false.
 * @Provenance Extra: the two returns stay distinct; false is the empty/default bool.
 */

namespace ControlFlowTest
{
	/**
	 * A function returning true.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A function body returning true
	 * @Return true
	 */
	bool TrueReturn()
	{
		return true;
	}

	/**
	 * A function returning false.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A function body returning false
	 * @Return false
	 */
	bool FalseReturn()
	{
		return false;
	}

	/**
	 * Observe that each returner delivers its own flag.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call both returners
	 * @Return true when one is true and the other false
	 */
	UFUNCTION()
	bool BoolReturnersDeliverTheirOwnFlag()
	{
		if (TrueReturn() != true)
		{
			return false;
		}
		return FalseReturn() == false;
	}

	/**
	 * Observe the false default: an uninitialised bool is false, so a false
	 * return matches it.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare a false return against an uninitialised bool
	 * @Return true when both are false
	 * @Boundary default bool
	 */
	UFUNCTION()
	bool FalseReturnMatchesDefaultBool()
	{
		bool Empty;
		if (Empty != false)
		{
			return false;
		}
		return FalseReturn() == Empty;
	}

	/**
	 * Observe that the two returners remain distinct.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the two returners against each other
	 * @Return true when their flags differ
	 */
	UFUNCTION()
	bool BoolReturnersStayDistinct()
	{
		return TrueReturn() != FalseReturn();
	}
}
