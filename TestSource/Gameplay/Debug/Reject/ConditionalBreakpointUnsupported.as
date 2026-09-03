/**
 * SetConditionalBreakpoint is a debugger-client feature rather than a script
 * callable, so this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_ConditionalBreakpointUnsupported and expects the diagnostic to name
 * SetConditionalBreakpoint. The CSV Positive label is wrong; C++ does not compile
 * this.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ConditionalBreakpointUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.ConditionalBreakpointUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: SetConditionalBreakpoint is client-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: SetConditionalBreakpoint (debugger-client, not an AS callable API).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetConditionalBreakpoint.
 */

/**
 * The isolated failing program: SetConditionalBreakpoint has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Debug.ConditionalBreakpointUnsupported
 * @Inputs none
 * @Return does not compile; SetConditionalBreakpoint belongs to the IDE debugger client
 */
void TryConditionalBreakpoint()
{
	SetConditionalBreakpoint("Coverage_DebugAndLogging.as", 15, "Value > 10");
}
