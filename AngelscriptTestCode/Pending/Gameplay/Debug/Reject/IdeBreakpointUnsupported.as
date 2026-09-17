/**
 * @version v1
 * @summary SetBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_IdeBreakpointUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary SetBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_IdeBreakpointUnsupported and expects the diagnostic to name.
 * @topic Negative
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
/** @end */
