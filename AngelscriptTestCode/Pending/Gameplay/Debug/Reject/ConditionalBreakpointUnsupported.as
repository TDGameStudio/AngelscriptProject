/**
 * @version v1
 * @summary SetConditionalBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ConditionalBreakpointUnsupported and expects the diagnostic.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary SetConditionalBreakpoint is a debugger-client feature rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ConditionalBreakpointUnsupported and expects the diagnostic.
 * @topic Negative
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
/** @end */
