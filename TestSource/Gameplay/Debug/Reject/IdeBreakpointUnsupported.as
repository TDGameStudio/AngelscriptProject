/**
 * SetBreakpoint is a debugger-client feature rather than a script callable, so this
 * program is rejected. C++ compiles it as the module
 * ASCoverageDebug_IdeBreakpointUnsupported and expects the diagnostic to name
 * SetBreakpoint.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.IdeBreakpointUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.IdeBreakpointUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: SetBreakpoint is debugger-client only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
 * @Provenance Expected diagnostic: SetBreakpoint (IDE breakpoint management is not an AS callable API).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop SetBreakpoint.
 */

/**
 * The isolated failing program: SetBreakpoint has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.IdeBreakpointUnsupported
 * @Inputs none
 * @Return does not compile; SetBreakpoint belongs to the IDE debugger client
 */
void TryIdeDebuggerControls()
{
	SetBreakpoint("Coverage_DebugAndLogging.as", 12);
}
