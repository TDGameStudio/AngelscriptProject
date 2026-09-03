/**
 * A function declared to return an int returns its value on every exit path,
 * and the caller receives that value rather than a default. An uninitialised
 * local, by contrast, holds zero, so the returned value is distinguishable
 * from an unset one.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnInt
 * @Harness Function
 * @Tag Language.ControlFlow.ReturnInt
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=d62df7436867c43ba55e7f6166a0a28ceded6b4ce9d7632f82345c50ac214292; lines 538-540.
 * @Provenance Oracle: Test() returns 42.
 * @Provenance Extra: 42 is not the default 0.
 */

namespace ControlFlowTest
{
	/**
	 * A function returning a fixed int.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A function body returning 42
	 * @Return 42
	 */
	int FixedIntReturn()
	{
		return 42;
	}

	/**
	 * Observe that the caller receives the returned value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the returning function
	 * @Return true when the result is 42
	 */
	UFUNCTION()
	bool IntReturnDeliversValue()
	{
		return FixedIntReturn() == 42;
	}

	/**
	 * Observe that the returned value is not the default an uninitialised local
	 * would hold.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the returned value against an uninitialised int
	 * @Return true when the local is zero and the return differs from it
	 * @Boundary default value comparison
	 */
	UFUNCTION()
	bool IntReturnDiffersFromDefault()
	{
		int Empty;
		if (Empty != 0)
		{
			return false;
		}
		return FixedIntReturn() != Empty;
	}
}
