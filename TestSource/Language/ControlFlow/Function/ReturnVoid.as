/**
 * A bare return in a void function is legal: it exits the function without a
 * value. Calling such a function repeatedly completes the same way, and the
 * caller carries on after each call.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnVoid
 * @Harness Function
 * @Tag Language.ControlFlow.ReturnVoid
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=44b53a8662227b736f6ea9a7bf927d98d0f95db7076304279badec23ce29acb5; lines 531-533.
 * @Provenance Oracle: void return compiles; Test() completes without a value.
 * @Provenance Extra: calling Test twice remains a completed void return.
 */

namespace ControlFlowTest
{
	/**
	 * A void function that exits with a bare return.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A void function body ending in a bare return
	 * @Return nothing
	 */
	void BareVoidReturn()
	{
		return;
	}

	/**
	 * Observe that a void function can be called and that control returns to
	 * the caller afterwards.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the void function once, then continue
	 * @Return true when the call completed and the next statement ran
	 */
	UFUNCTION()
	bool VoidReturnCompletesAndContinues()
	{
		BareVoidReturn();
		return true;
	}

	/**
	 * Observe that repeated calls complete the same way.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the void function twice, then continue
	 * @Return true when both calls completed
	 */
	UFUNCTION()
	bool RepeatedVoidReturnsComplete()
	{
		BareVoidReturn();
		BareVoidReturn();
		return true;
	}
}
