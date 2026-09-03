/**
 * Watch and EvaluateImmediate are debugger-client features rather than script
 * callables, so this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_WatchImmediateUnsupported and expects the diagnostic to name Watch.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.WatchImmediateUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.WatchImmediateUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: Watch/EvaluateImmediate are client-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: Watch (watch and immediate-window evaluation are not AS callable APIs).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Watch.
 */

/**
 * The isolated failing program: Watch and EvaluateImmediate have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.WatchImmediateUnsupported
 * @Inputs none
 * @Return does not compile; watch and immediate-window evaluation belong to the debugger client
 */
void TryWatchAndImmediate()
{
	Watch("Value");
	EvaluateImmediate("Value + 1");
}
