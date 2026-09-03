/**
 * The native SCOPE_CYCLE_COUNTER macro is not visible to script, so this program is
 * rejected. C++ compiles it as the module
 * ASCoverageDebug_ScopeCycleCounterUnsupported and expects the diagnostic to name
 * the stat it declares.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ScopeCycleCounterUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.ScopeCycleCounterUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: native SCOPE_CYCLE_COUNTER macro.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
 * @Provenance Expected diagnostic: STAT_CoverageDebugAndLogging (macro is not AS-facing).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SCOPE_CYCLE_COUNTER.
 */

/**
 * The isolated failing program: the SCOPE_CYCLE_COUNTER macro has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Debug.ScopeCycleCounterUnsupported
 * @Inputs none
 * @Return does not compile; SCOPE_CYCLE_COUNTER is a native macro
 */
void TryNativeProfilerMacro()
{
	SCOPE_CYCLE_COUNTER(STAT_CoverageDebugAndLogging);
}
