/**
 * @version v1
 * @summary SetLogBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_LogBreakpointUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary SetLogBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_LogBreakpointUnsupported and expects the diagnostic to name.
 * @topic Negative
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
/** @end */
