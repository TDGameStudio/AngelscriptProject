/**
 * StepOver, StepInto and StepOut are driven by the debugger client rather than being
 * script callables, so this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_StepControlsUnsupported and expects the diagnostic to name StepOver.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.StepControlsUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.StepControlsUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: StepOver/StepInto/StepOut are client-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: StepOver (stepping is driven by debugger clients).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop StepOver.
 */

/**
 * The isolated failing program: the stepping controls have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.StepControlsUnsupported
 * @Inputs none
 * @Return does not compile; stepping is driven by debugger clients
 */
void TryStepControls()
{
	StepOver();
	StepInto();
	StepOut();
}
