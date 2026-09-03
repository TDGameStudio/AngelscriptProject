/**
 * DebugBreak is reachable from script and safe under automation, where the C++ harness
 * installs an override that turns it into a no-op. C++ executes the entrypoint and
 * expects 7 regardless of whether the break did anything.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DebugBreakBindingCanBeDisabledForAutomation
 * @Harness Function
 * @Tag Gameplay.Debug.DebugBreakBindingCanBeDisabledForAutomation
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Positive: DebugBreak is script-facing and automation-safe.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebugBreakBindingCanBeDisabledForAutomation
 * @Provenance ExecuteAndExpectInt TriggerDebugBreak == 7. Extra: the return is independent of
 * @Provenance DebugBreak being a no-op under the C++ override. DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * Observe that calling DebugBreak returns control to the caller under automation.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugBreakBindingCanBeDisabledForAutomation
	 * @Inputs none
	 * @Return 7 once DebugBreak has returned
	 */
	UFUNCTION()
	int TriggerDebugBreak()
	{
		DebugBreak();
		return 7;
	}

	/**
	 * Observe that driving the debug break reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugBreakBindingCanBeDisabledForAutomation
	 * @Inputs none
	 * @Return true when the entrypoint returned 7
	 */
	UFUNCTION()
	bool TriggerDebugBreakNominal()
	{
		return TriggerDebugBreak() == 7;
	}

	/**
	 * Observe the baseline score before the break is reached.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugBreakBindingCanBeDisabledForAutomation
	 * @Inputs none
	 * @Return 0, the score before any work is done
	 * @Boundary before call
	 */
	UFUNCTION()
	int DefaultBeforeCall()
	{
		int Score = 0;
		return Score;
	}
}
