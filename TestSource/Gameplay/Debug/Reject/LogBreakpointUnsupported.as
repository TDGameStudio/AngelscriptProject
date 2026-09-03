/**
 * SetLogBreakpoint is a debugger-client feature rather than a script callable, so
 * this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_LogBreakpointUnsupported and expects the diagnostic to name
 * SetLogBreakpoint. The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.LogBreakpointUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.LogBreakpointUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: SetLogBreakpoint is client-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: SetLogBreakpoint (debugger-client, not an AS callable API).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetLogBreakpoint.
 */

/**
 * The isolated failing program: SetLogBreakpoint has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.LogBreakpointUnsupported
 * @Inputs none
 * @Return does not compile; SetLogBreakpoint belongs to the IDE debugger client
 */
void TryLogBreakpoint()
{
	SetLogBreakpoint("Coverage_DebugAndLogging.as", 16, "Value={Value}");
}
